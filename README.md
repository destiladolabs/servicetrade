# ServiceTrade Ruby

A Ruby client library for the ServiceTrade API.

[![Gem Version](https://badge.fury.io/rb/servicetrade.svg)](https://badge.fury.io/rb/servicetrade)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'servicetrade'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install servicetrade

## Configuration

The gem supports two authentication methods:

### Option 1: API Token Authentication (Recommended)

```ruby
ServiceTrade.configure do |config|
  config.api_token = 'your_api_token'
  config.api_version = '1'  # Optional, defaults to '1'
  config.timeout = 30       # Optional, defaults to 30 seconds
  config.open_timeout = 10  # Optional, defaults to 10 seconds
end
```

### Option 2: Username/Password Authentication

```ruby
ServiceTrade.configure do |config|
  config.username = 'your_username'
  config.password = 'your_password'
  config.api_version = '1'  # Optional, defaults to '1'
  config.timeout = 30       # Optional, defaults to 30 seconds
  config.open_timeout = 10  # Optional, defaults to 10 seconds
end
```

### Using Environment Variables

```ruby
# For token authentication
ServiceTrade.configure do |config|
  config.api_token = ENV['SERVICETRADE_API_TOKEN']
end

# For username/password authentication
ServiceTrade.configure do |config|
  config.username = ENV['SERVICETRADE_USERNAME']
  config.password = ENV['SERVICETRADE_PASSWORD']
end
```

## Authentication

### Automatic Authentication

The gem automatically handles authentication based on your configuration:

- **Token Authentication**: Uses your API token with the `X-Auth-Token` header
- **Session Authentication**: Uses username/password with session management handled internally

### Manual Authentication Methods

You can also authenticate manually and obtain API tokens:

```ruby
# Authenticate with username/password to get an API token
auth_response = ServiceTrade::Auth.authenticate_with_credentials('username', 'password')
api_token = auth_response['authToken']

# Set the token for future requests
ServiceTrade::Auth.set_api_token(api_token, auth_response['user'])

# Or configure it globally
ServiceTrade.configure do |config|
  config.api_token = api_token
end
```

### OAuth Authentication

For OAuth flows, you can authenticate with OAuth tokens:

```ruby
# Authenticate with OAuth tokens (id_token and access_token)
auth_response = ServiceTrade::Auth.authenticate_with_oauth_tokens(id_token, access_token)
api_token = auth_response['authToken']

# Set the token for future requests
ServiceTrade::Auth.set_api_token(api_token, auth_response['user'])
```

### Checking Authentication Status

```ruby
# Check if currently authenticated
if ServiceTrade::Auth.authenticated?
  puts "Ready to make API calls"
else
  puts "Authentication required"
end

# Get current user information
user_info = ServiceTrade::Auth.current_user_info
puts "Logged in as: #{user_info['user']['username']}"
```

### Logout

```ruby
# Logout and invalidate current session/token
ServiceTrade::Auth.logout
```

## Usage

### Jobs

```ruby
# List all jobs
jobs = ServiceTrade::Job.list

# Create a new job
job = ServiceTrade::Job.create(
  name: 'Service Call',
  customer_id: 123,
  location_id: 456,
  scheduled_date: '2023-12-01'
)

# Update a job
ServiceTrade::Job.update(job_id, {
  status: 'completed',
  completed_date: Time.now.iso8601
})

# Delete a job
ServiceTrade::Job.delete(job_id)
```

### Appointments

```ruby
# List appointments
appointments = ServiceTrade::Appointment.list

# Create an appointment
appointment = ServiceTrade::Appointment.create(
  job_id: 123,
  start_time: '2023-12-01T09:00:00Z',
  end_time: '2023-12-01T10:00:00Z'
)
```

### Locations

```ruby
# List locations
locations = ServiceTrade::Location.list

# Create a location
location = ServiceTrade::Location.create(
  name: 'Customer Site',
  address: '123 Main St',
  city: 'Anytown',
  state: 'CA',
  zip: '12345'
)
```

## Error Handling

The gem provides specific error classes with helpful error messages:

### Configuration Errors

The gem will provide clear guidance if you haven't configured your credentials:

```ruby
begin
  ServiceTrade::Job.list
rescue ServiceTrade::ConfigurationError => e
  puts e.message
  # Outputs helpful message with configuration examples
end
```

### API Errors

```ruby
begin
  job = ServiceTrade::Job.create(invalid_data)
rescue ServiceTrade::ConfigurationError => e
  # Handle missing or invalid configuration
  puts "Configuration error: #{e.message}"
rescue ServiceTrade::AuthenticationError => e
  # Handle authentication errors (401) with enhanced messaging
  puts "Authentication failed: #{e.message}"
rescue ServiceTrade::AuthorizationError => e
  # Handle authorization errors (403)
  puts "Not authorized: #{e.message}"
rescue ServiceTrade::NotFoundError => e
  # Handle not found errors (404)
  puts "Resource not found: #{e.message}"
rescue ServiceTrade::ApiError => e
  # Handle other API errors
  puts "API error: #{e.message}"
end
```

### Configuration Validation

You can check if your configuration is valid:

```ruby
# Check if configured
if ServiceTrade.configured?
  puts "Ready to make API calls"
else
  puts "Please configure your credentials first"
end

# Validate configuration (raises error if invalid)
ServiceTrade.validate_configuration!
```

## Available Resources

- **Job** - Create, read, update, and delete jobs
- **Appointment** - Manage appointments associated with jobs
- **Location** - Manage customer locations

Each resource supports standard CRUD operations where applicable:
- `list` - Retrieve a list of resources
- `create(params)` - Create a new resource
- `update(id, params)` - Update an existing resource
- `delete(id)` - Delete a resource

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/destilado/servicetrade-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).