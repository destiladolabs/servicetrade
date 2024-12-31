module ServiceTrade
  class Auth
    attr_reader :session_id
    
    def initialize
      @session_id = nil
      @last_auth_time = nil
    end
    
    def authenticate
      response = Client.new.request(
        :post,
        'auth',
        {
          username: ServiceTrade.configuration.username,
          password: ServiceTrade.configuration.password
        },
        skip_auth: true
      )
      
      @session_id = response['sessionId']
      @last_auth_time = Time.now
      
      @session_id
    end
    
    def session_id
      if @session_id.nil? || session_expired?
        authenticate
      end
      @session_id
    end
    
    private
    
    def session_expired?
      return true if @last_auth_time.nil?
      # ServiceTrade sessions typically expire after 24 hours
      Time.now - @last_auth_time > 86400 # 24 hours in seconds
    end
  end
end