module ServiceTrade
  class Configuration
    attr_accessor :username, :password, :api_version, :timeout, :open_timeout
    
    def initialize
      @api_version = '1'
      @timeout = 30
      @open_timeout = 10
    end
  end
end