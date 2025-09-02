# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Setup and Installation
- `bin/setup` - Install dependencies
- `bundle install` - Install Ruby gems
- `bin/console` - Open interactive console with gem loaded

### Testing
- `bundle exec ruby test/servicetrade_test.rb` - Run tests
- Use minitest framework with webmock for HTTP mocking

### Code Quality
- `bundle exec rubocop` - Run linter (Ruby 2.7+ only)
- `bundle exec sorbet tc` - Run type checker
- `bundle exec tapioca dsl` - Generate type annotations for gems

### Gem Management
- `bundle exec rake build` - Build gem
- `bundle exec rake install` - Install gem locally
- `bundle exec rake release` - Release new version

## Architecture Overview

This is a Ruby client library for the ServiceTrade API following a modular, extensible design pattern:

### Core Components

**Client Layer (`lib/servicetrade/client.rb`)**
- Handles HTTP requests to ServiceTrade API
- Manages authentication headers and session tokens
- Implements error handling with specific exception classes
- Uses Net::HTTP with configurable timeouts

**Authentication (`lib/servicetrade/auth.rb`)**
- Session-based authentication with automatic token refresh
- 24-hour session expiration handling
- Credentials managed through configuration

**Configuration (`lib/servicetrade/configuration.rb`)**
- Username/password credentials
- API version (defaults to '1')
- Timeout settings (connection: 10s, read: 30s)

**Error Hierarchy (`lib/servicetrade/errors.rb`)**
- Base `ServiceTrade::Error` class
- HTTP-specific errors: `AuthenticationError` (401), `AuthorizationError` (403), `NotFoundError` (404)
- Generic `ApiError` for other failures

### Resource Architecture

**Base Resource Pattern (`lib/servicetrade/resources/base_resource.rb`)**
- Common initialization and attribute handling
- Dynamic attribute setting for API responses

**API Operations Modules (`lib/servicetrade/api_operations/`)**
- `Create` - POST requests for resource creation
- `List` - GET requests with pagination support via `ListResponse` class
- `Update` - PUT/PATCH requests for modifications
- `Delete` - DELETE requests for removal
- Modules are mixed into resource classes as needed

**Available Resources**
- `Job` - Service jobs with full CRUD operations
- `Appointment` - Scheduling functionality  
- `Location` - Customer location management

### Key Design Patterns

**Pagination Handling**
- `ListResponse` class wraps paginated API responses
- `all` method provides automatic pagination iteration
- Supports both block iteration and Enumerator interface

**Module-based API Operations**
- Each CRUD operation is a separate module
- Resources extend only needed operations
- Consistent interface across all resources

**Configuration Management**
- Global configuration through `ServiceTrade.configure` block
- Singleton pattern for auth and client instances

## Type Safety

Uses Sorbet for gradual typing:
- Type signatures in `.rbi` files under `sorbet/rbi/`
- Tapioca generates RBI files for gems
- Run `sorbet tc` for type checking

## Testing Strategy

- Minitest framework in `test/` directory
- WebMock for HTTP request stubbing
- Test helper loads gem and sets up WebMock
- Focus on integration-style tests for API client behavior