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

Configure the client with your ServiceTrade credentials:

```ruby
ServiceTrade.configure do |config|
  config.username = 'your_username'
  config.password = 'your_password'
  config.api_version = '1'  # Optional, defaults to '1'
  config.timeout = 30       # Optional, defaults to 30 seconds
  config.open_timeout = 10  # Optional, defaults to 10 seconds
end
```

## Authentication

The gem automatically handles authentication with the ServiceTrade API using your username and password. Session management is handled internally.

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

The gem provides specific error classes for different types of API errors:

```ruby
begin
  job = ServiceTrade::Job.create(invalid_data)
rescue ServiceTrade::AuthenticationError => e
  # Handle authentication errors (401)
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