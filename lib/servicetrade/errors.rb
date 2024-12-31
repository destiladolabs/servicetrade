module ServiceTrade
  class Error < StandardError; end
  class ApiError < Error; end
  class AuthenticationError < Error; end
  class AuthorizationError < Error; end
  class NotFoundError < Error; end
end