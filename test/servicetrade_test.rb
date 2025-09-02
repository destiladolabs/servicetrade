# frozen_string_literal: true

require "test_helper"

class ServiceTradeTest < Minitest::Test
  def test_has_version_number
    refute_nil ::ServiceTrade::VERSION
  end

  def test_configuration
    ServiceTrade.configure do |config|
      config.username = "test_username"
      config.password = "test_password"
    end

    assert_equal "test_username", ServiceTrade.configuration.username
    assert_equal "test_password", ServiceTrade.configuration.password
  end

  def teardown
    ServiceTrade.reset_configuration
  end
end
