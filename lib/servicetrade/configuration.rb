module ServiceTrade
  class Configuration
    attr_accessor :username, :password, :api_token, :api_version, :timeout, :open_timeout
    
    def initialize
      @api_version = '1'
      @timeout = 30
      @open_timeout = 10
    end
    
    def valid?
      # Valid if either token auth or username/password auth is configured
      token_auth_configured? || username_password_auth_configured?
    end
    
    def token_auth_configured?
      !api_token.nil? && !api_token.strip.empty?
    end
    
    def username_password_auth_configured?
      !username.nil? && !username.strip.empty? &&
      !password.nil? && !password.strip.empty?
    end
    
    def validate!
      return if valid?
      
      error_message = "ServiceTrade configuration is incomplete. You must configure either:\n\n" +
                     "Option 1 - API Token Authentication (recommended):\n" +
                     "ServiceTrade.configure do |config|\n" +
                     "  config.api_token = 'your_api_token'\n" +
                     "end\n\n" +
                     "Option 2 - Username/Password Authentication:\n" +
                     "ServiceTrade.configure do |config|\n" +
                     "  config.username = 'your_username'\n" +
                     "  config.password = 'your_password'\n" +
                     "end\n\n" +
                     "You can also use environment variables:\n" +
                     "# For token auth:\n" +
                     "ServiceTrade.configure do |config|\n" +
                     "  config.api_token = ENV['SERVICETRADE_API_TOKEN']\n" +
                     "end\n\n" +
                     "# For username/password auth:\n" +
                     "ServiceTrade.configure do |config|\n" +
                     "  config.username = ENV['SERVICETRADE_USERNAME']\n" +
                     "  config.password = ENV['SERVICETRADE_PASSWORD']\n" +
                     "end\n\n" +
                     "To get an API token, authenticate once with username/password:\n" +
                     "auth_response = ServiceTrade::Auth.authenticate_with_credentials('username', 'password')\n" +
                     "api_token = auth_response['authToken']"
      
      raise ServiceTrade::ConfigurationError, error_message
    end
    
    def configured?
      valid?
    end
  end
end