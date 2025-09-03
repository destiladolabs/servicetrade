# frozen_string_literal: true

require_relative "test_helper"

class ConfigurationTest < Test::Unit::TestCase
  def setup
    ServiceTrade.reset!
  end

  def teardown
    ServiceTrade.reset!
  end

  def test_unconfigured_state
    refute ServiceTrade.configured?
    
    assert_raises(ServiceTrade::ConfigurationError) do
      ServiceTrade.validate_configuration!
    end
  end

  def test_missing_username
    ServiceTrade.configure do |config|
      config.password = "test_password"
      # username intentionally not set
    end

    refute ServiceTrade.configured?
    
    error = assert_raises(ServiceTrade::ConfigurationError) do
      ServiceTrade.configuration.validate!
    end
    
    assert_match(/ServiceTrade configuration is incomplete/, error.message)
    assert_match(/Option 1 - API Token Authentication/, error.message)
  end

  def test_missing_password
    ServiceTrade.configure do |config|
      config.username = "test_user"
      # password intentionally not set
    end

    refute ServiceTrade.configured?
    
    error = assert_raises(ServiceTrade::ConfigurationError) do
      ServiceTrade.configuration.validate!
    end
    
    assert_match(/ServiceTrade configuration is incomplete/, error.message)
    assert_match(/Option 2 - Username\/Password Authentication/, error.message)
  end

  def test_empty_username
    ServiceTrade.configure do |config|
      config.username = "  "  # whitespace only
      config.password = "test_password"
    end

    refute ServiceTrade.configured?
    
    error = assert_raises(ServiceTrade::ConfigurationError) do
      ServiceTrade.configuration.validate!
    end
    
    assert_match(/ServiceTrade configuration is incomplete/, error.message)
  end

  def test_empty_password
    ServiceTrade.configure do |config|
      config.username = "test_user"
      config.password = ""  # empty string
    end

    refute ServiceTrade.configured?
    
    error = assert_raises(ServiceTrade::ConfigurationError) do
      ServiceTrade.configuration.validate!
    end
    
    assert_match(/ServiceTrade configuration is incomplete/, error.message)
  end

  def test_missing_both_credentials
    ServiceTrade.configure do |config|
      # neither username nor password set
    end

    refute ServiceTrade.configured?
    
    error = assert_raises(ServiceTrade::ConfigurationError) do
      ServiceTrade.configuration.validate!
    end
    
    assert_match(/ServiceTrade configuration is incomplete/, error.message)
    assert_match(/ServiceTrade configuration is incomplete/, error.message)
    assert_match(/Option 1 - API Token Authentication/, error.message)
    assert_match(/environment variables/, error.message)
  end

  def test_valid_configuration
    ServiceTrade.configure do |config|
      config.username = "test_user"
      config.password = "test_password"
    end

    assert ServiceTrade.configured?
    assert ServiceTrade.configuration.valid?
    assert ServiceTrade.configuration.configured?
    
    # Should not raise an error
    assert_nothing_raised do
      ServiceTrade.configuration.validate!
    end
  end

  def test_auth_validates_configuration_before_request
    # Don't configure anything
    
    error = assert_raises(ServiceTrade::ConfigurationError) do
      ServiceTrade.auth.authenticate
    end
    
    assert_match(/ServiceTrade has not been configured/, error.message)
    assert_match(/ServiceTrade\.configure/, error.message)
  end

  def test_auth_validates_incomplete_configuration
    ServiceTrade.configure do |config|
      config.username = "test_user"
      # password missing
    end
    
    error = assert_raises(ServiceTrade::ConfigurationError) do
      ServiceTrade.auth.authenticate
    end
    
    assert_match(/ServiceTrade configuration is incomplete/, error.message)
  end

  def test_enhanced_authentication_error_message
    ServiceTrade.configure do |config|
      config.username = "test_user"
      config.password = "wrong_password"
    end

    # Stub a 401 response
    stub_request(:post, "https://api.servicetrade.com/api/auth")
      .to_return(status: 401, body: '{"error": "Invalid credentials"}')

    error = assert_raises(ServiceTrade::AuthenticationError) do
      ServiceTrade.auth.authenticate
    end

    assert_match(/Invalid credentials/, error.message)
    assert_match(/This usually means:/, error.message)
    assert_match(/username or password is incorrect/, error.message)
    assert_match(/verify your credentials/, error.message)
  end

  def test_configuration_methods_exist
    assert_respond_to ServiceTrade, :configured?
    assert_respond_to ServiceTrade, :validate_configuration!
    assert_respond_to ServiceTrade::Configuration.new, :valid?
    assert_respond_to ServiceTrade::Configuration.new, :validate!
    assert_respond_to ServiceTrade::Configuration.new, :configured?
  end
end