#!/usr/bin/env ruby
# frozen_string_literal: true

# Example demonstrating improved error handling for ServiceTrade configuration
# This file shows the helpful error messages users will see when configuration is missing or invalid

require_relative '../lib/servicetrade'

puts "ServiceTrade Error Handling Examples"
puts "=" * 50

# Example 1: No configuration at all
puts "\n1. Attempting to use ServiceTrade without any configuration:"
puts "-" * 50

begin
  ServiceTrade::Job.list
rescue ServiceTrade::ConfigurationError => e
  puts "❌ Configuration Error:"
  puts e.message
end

# Example 2: Missing username
puts "\n2. Configuration with missing username:"
puts "-" * 50

ServiceTrade.reset!
begin
  ServiceTrade.configure do |config|
    config.password = "some_password"
    # username intentionally missing
  end
  
  ServiceTrade::Job.list
rescue ServiceTrade::ConfigurationError => e
  puts "❌ Configuration Error:"
  puts e.message
end

# Example 3: Missing password
puts "\n3. Configuration with missing password:"
puts "-" * 50

ServiceTrade.reset!
begin
  ServiceTrade.configure do |config|
    config.username = "some_username"
    # password intentionally missing
  end
  
  ServiceTrade::Job.list
rescue ServiceTrade::ConfigurationError => e
  puts "❌ Configuration Error:"
  puts e.message
end

# Example 4: Empty credentials
puts "\n4. Configuration with empty credentials:"
puts "-" * 50

ServiceTrade.reset!
begin
  ServiceTrade.configure do |config|
    config.username = "  "  # whitespace only
    config.password = ""    # empty string
  end
  
  ServiceTrade::Job.list
rescue ServiceTrade::ConfigurationError => e
  puts "❌ Configuration Error:"
  puts e.message
end

# Example 5: Wrong credentials (authentication error)
puts "\n5. Configuration with incorrect credentials:"
puts "-" * 50

ServiceTrade.reset!
begin
  ServiceTrade.configure do |config|
    config.username = "wrong_username"
    config.password = "wrong_password"
  end
  
  # This would normally make an HTTP request and fail with 401
  # For demo purposes, we'll simulate this
  puts "This would result in an enhanced authentication error:"
  puts ""
  puts "❌ Authentication Error:"
  puts "Invalid credentials or expired session"
  puts ""
  puts "This usually means:"
  puts "• Your ServiceTrade username or password is incorrect"
  puts "• Your ServiceTrade account may be locked or suspended"
  puts "• The ServiceTrade API may be temporarily unavailable"
  puts ""
  puts "Please verify your credentials and try again."
  
rescue => e
  puts "❌ Error: #{e.message}"
end

# Example 6: Checking configuration status
puts "\n6. Checking configuration status:"
puts "-" * 50

ServiceTrade.reset!
puts "Before configuration:"
puts "ServiceTrade.configured? = #{ServiceTrade.configured?}"

ServiceTrade.configure do |config|
  config.username = "valid_username"
  config.password = "valid_password"
end

puts "After valid configuration:"
puts "ServiceTrade.configured? = #{ServiceTrade.configured?}"

# Example 7: Correct configuration
puts "\n7. Correct configuration example:"
puts "-" * 50

puts "✅ Proper ServiceTrade configuration:"
puts ""
puts "ServiceTrade.configure do |config|"
puts "  config.username = ENV['SERVICETRADE_USERNAME'] || 'your_username'"
puts "  config.password = ENV['SERVICETRADE_PASSWORD'] || 'your_password'"
puts "end"
puts ""
puts "Or with direct values:"
puts ""
puts "ServiceTrade.configure do |config|"
puts "  config.username = 'your_servicetrade_username'"
puts "  config.password = 'your_servicetrade_password'"
puts "end"

puts "\n" + "=" * 50
puts "These enhanced error messages help users quickly identify and fix configuration issues!"