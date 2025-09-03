module ServiceTrade
  class Auth
    attr_reader :session_id, :auth_token, :user_info

    def initialize
      @session_id = nil
      @auth_token = nil
      @user_info = nil
      @last_auth_time = nil
    end

    def authenticate
      # Validate configuration before attempting authentication
      validate_configuration!

      response = Client.new.request(
        :post,
        'auth',
        {
          username: ServiceTrade.configuration.username,
          password: ServiceTrade.configuration.password
        },
        skip_auth: true
      )

      # Handle both nested and direct response formats
      # sessionId is at the root level, authToken is inside data
      @session_id = response['sessionId']
      
      auth_data = response['data'] || response
      @auth_token = auth_data['authToken']  # Store the auth token as well
      @user_info = auth_data
      @last_auth_time = Time.now
      
      # If we got an auth token, update the configuration to use it for future requests
      if @auth_token && !@auth_token.empty?
        ServiceTrade.configuration.api_token = @auth_token
      end

      @session_id
    rescue ServiceTrade::AuthenticationError => e
      # Enhance authentication error with helpful message
      enhanced_message = "#{e.message}\n\n" +
                        "This usually means:\n" +
                        "• Your ServiceTrade username or password is incorrect\n" +
                        "• Your ServiceTrade account may be locked or suspended\n" +
                        "• The ServiceTrade API may be temporarily unavailable\n\n" +
                        "Please verify your credentials and try again."

      raise ServiceTrade::AuthenticationError, enhanced_message
    end

    def session_id
      if @session_id.nil? || session_expired?
        authenticate
      end
      @session_id
    end

    class << self
      # Class methods for OAuth-style authentication

      # Authenticate with username/password and return full response including token
      def authenticate_with_credentials(username = nil, password = nil)
        # Ensure we have basic configuration for the HTTP client to work
        ensure_basic_configuration!

        username ||= ServiceTrade.configuration.username
        password ||= ServiceTrade.configuration.password

        response = ServiceTrade::Client.new.request(
          :post,
          'auth',
          {
            username: username,
            password: password
          },
          {},
          skip_auth: true
        )

        # Handle both nested and direct response formats
        auth_data = response['data'] || response
        unless auth_data['authenticated']
          error_message = response.dig('messages', 'error')&.first || 'Authentication failed'
          raise ServiceTrade::AuthenticationError, enhance_auth_error_message(error_message)
        end

        auth_data
      rescue ServiceTrade::AuthenticationError
        raise
      rescue ServiceTrade::AuthorizationError
        # Handle 403 errors from bad credentials
        error_message = 'Invalid credentials provided'
        raise ServiceTrade::AuthenticationError, enhance_auth_error_message(error_message)
      rescue StandardError => e
        raise ServiceTrade::AuthenticationError, "Authentication request failed: #{e.message}"
      end

      # Authenticate with OAuth tokens (id_token and access_token)
      def authenticate_with_oauth_tokens(id_token, access_token)
        # Ensure we have basic configuration for the HTTP client to work
        ensure_basic_configuration!

        response = ServiceTrade::Client.new.request(
          :post,
          'auth/userinfo',
          {
            id_token: id_token,
            access_token: access_token
          },
          {},
          skip_auth: true
        )

        # Handle both nested and direct response formats
        auth_data = response['data'] || response
        unless auth_data['authenticated']
          error_message = response.dig('messages', 'error')&.first || 'OAuth authentication failed'
          raise ServiceTrade::AuthenticationError, "#{error_message}\n\n" \
                                                   "Please verify your OAuth tokens are valid and try again."
        end

        auth_data
      rescue ServiceTrade::AuthenticationError
        raise
      rescue ServiceTrade::AuthorizationError
        # Handle 403 errors from bad OAuth tokens
        error_message = 'invalid id_token or access_token'
        raise ServiceTrade::AuthenticationError, "#{error_message}\n\n" \
                                                 "Please verify your OAuth tokens are valid and try again."
      rescue StandardError => e
        raise ServiceTrade::AuthenticationError, "OAuth authentication request failed: #{e.message}"
      end

      # Get current authentication info (requires active session or token)
      def current_user_info
        response = ServiceTrade::Client.new.request(:get, 'auth')

        # Handle both nested and direct response formats
        auth_data = response['data'] || response
        unless auth_data['authenticated']
          raise ServiceTrade::AuthenticationError, "No active authentication session found"
        end

        auth_data
      rescue ServiceTrade::NotFoundError
        raise ServiceTrade::AuthenticationError, "No active authentication session found"
      end

      # Logout/delete current session
      def logout
        ServiceTrade::Client.new.request(:delete, 'auth')
        true
      rescue ServiceTrade::NotFoundError
        # Already logged out
        true
      end

      # Set API token directly (for when user already has a token)
      def set_api_token(token, user_info = nil)
        ServiceTrade.configure do |config|
          config.api_token = token
        end

        # Store user info if provided
        ServiceTrade.auth.instance_variable_set(:@auth_token, token)
        ServiceTrade.auth.instance_variable_set(:@user_info, user_info)
        ServiceTrade.auth.instance_variable_set(:@last_auth_time, Time.now)

        true
      end

      # Check if currently authenticated (works with both token and session auth)
      def authenticated?
        return false unless ServiceTrade.configured?

        begin
          current_user_info
          true
        rescue ServiceTrade::AuthenticationError
          false
        end
      end

      private

      def enhance_auth_error_message(original_message)
        "#{original_message}\n\n" \
          "This usually means:\n" \
          "• Your ServiceTrade username or password is incorrect\n" \
          "• Your ServiceTrade account may be locked or suspended\n" \
          "• The ServiceTrade API may be temporarily unavailable\n\n" \
          "Please verify your credentials and try again."
      end

      def ensure_basic_configuration!
        # Ensure we have at least basic configuration for HTTP client to work
        ServiceTrade.configure unless ServiceTrade.configuration
      end
    end

    private

    def validate_configuration!
      # Only validate username/password auth since session auth needs credentials
      # Token auth doesn't need this validation
      return if ServiceTrade.configuration&.token_auth_configured?

      # Check if configuration exists
      if ServiceTrade.configuration.nil?
        raise ServiceTrade::ConfigurationError,
              "ServiceTrade has not been configured. Please run ServiceTrade.configure first:\n\n" \
              "ServiceTrade.configure do |config|\n" \
              "  config.username = 'your_servicetrade_username'\n" \
              "  config.password = 'your_servicetrade_password'\n" \
              "end"
      end

      # Validate username/password configuration
      return if ServiceTrade.configuration.username_password_auth_configured?

      # Use the enhanced configuration error message
      ServiceTrade.configuration.validate!
    end

    def session_expired?
      return true if @last_auth_time.nil?
      # ServiceTrade sessions typically expire after 24 hours
      Time.now - @last_auth_time > 86400 # 24 hours in seconds
    end
  end
end