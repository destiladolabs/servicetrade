module ServiceTrade
  class Client
    attr_reader :api_base

    def initialize
      @api_base = ServiceTrade.api_base
    end

    def request(method, path, params = {}, headers = {}, skip_auth: false)
      uri = URI.parse("#{api_base}/#{path}")

      # Set up the request
      klass = case method
      when :get
        Net::HTTP::Get
      when :post
        Net::HTTP::Post
      when :put
        Net::HTTP::Put
      when :delete
        Net::HTTP::Delete
      else
        raise ArgumentError, "Unknown HTTP method: #{method}"
      end

      request = klass.new(uri)

      # Add headers
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'
      unless skip_auth
        add_authentication_header(request)
      end
      headers.each { |key, value| request[key] = value }

      # Add parameters
      if [:post, :put].include?(method)
        request.body = params.to_json
      elsif method == :get && !params.empty?
        uri.query = URI.encode_www_form(params)
      end

      # Make the request
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.open_timeout = ServiceTrade.configuration.open_timeout
        http.read_timeout = ServiceTrade.configuration.timeout
        http.request(request)
      end

      handle_response(response)
    end

    private

    def add_authentication_header(request)
      config = ServiceTrade.configuration

      if config&.token_auth_configured?
        # Use API token authentication (preferred)
        request['X-Auth-Token'] = config.api_token
      elsif config&.username_password_auth_configured?
        # Fall back to session-based authentication
        request['X-Session-Id'] = ServiceTrade.auth.session_id
      else
        # This should be caught by validation, but just in case
        raise ServiceTrade::ConfigurationError, "No valid authentication method configured"
      end
    end

    def handle_response(response)
      case response.code.to_i
      when 200..299
        # Handle 204 No Content responses
        return {} if response.body.nil? || response.body.strip.empty?
        JSON.parse(response.body)
      when 401
        raise ServiceTrade::AuthenticationError, "Invalid credentials or expired session #{response.body}"
      when 403
        raise ServiceTrade::AuthorizationError, "Not authorized to perform this action"
      when 404
        raise ServiceTrade::NotFoundError, "Resource not found"
      else
        raise ServiceTrade::ApiError, "API error (#{response.code}): #{response.body}"
      end
    end
  end
end