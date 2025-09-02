#!/usr/bin/env ruby
# frozen_string_literal: true

# Example usage of the ServiceTrade Location API
# This file demonstrates the Location API functions implemented for the ServiceTrade Ruby gem

require_relative '../lib/servicetrade'

# Configure the client
ServiceTrade.configure do |config|
  config.username = ENV['SERVICETRADE_USERNAME'] || 'your_username'
  config.password = ENV['SERVICETRADE_PASSWORD'] || 'your_password'
end

begin
  puts "ServiceTrade Location API Examples"
  puts "=" * 40

  # List all customer locations (default behavior)
  puts "\n1. List all customer locations:"
  locations = ServiceTrade::Location.list
  puts "Found #{locations.length} customer locations"

  # List vendor offices only
  puts "\n2. List vendor offices:"
  vendor_locations = ServiceTrade::Location.vendors_only
  puts "Found #{vendor_locations.length} vendor offices"

  # Search locations by name
  puts "\n3. Search locations by name:"
  locations_by_name = ServiceTrade::Location.by_name('Restaurant')
  puts "Found #{locations_by_name.length} locations matching 'Restaurant'"

  # Find a specific location by ID
  puts "\n4. Find location by ID:"
  location = ServiceTrade::Location.find(123) # Replace with actual location ID
  puts "Location: #{location.name}"
  puts "Address: #{location.full_address}" if location.full_address
  puts "Status: #{location.status}"
  puts "Taxable: #{location.taxable? ? 'Yes' : 'No'}"

  # Create a new location
  puts "\n5. Create a new location:"
  new_location = ServiceTrade::Location.create(
    company_id: 30,
    name: 'API Test Location',
    address_street: '123 Test Ave',
    address_city: 'Testtown',
    address_state: 'NC',
    address_postal_code: '27560',
    phone_number: '(555) 123-4567',
    email: 'test@example.com',
    office_ids: [870],
    taxable: true
  )
  puts "Created location: #{new_location.name} (ID: #{new_location.id})"
  puts "Reference number: #{new_location.ref_number}"

  # Update a location
  puts "\n6. Update location with primary contact:"
  updated_location = ServiceTrade::Location.update(new_location.id, {
    primary_contact_id: 14, # Replace with actual contact ID
    general_manager: 'Jane Smith'
  })
  puts "Updated location with primary contact"
  puts "General Manager: #{updated_location.general_manager}" if updated_location.general_manager

  # List active locations only
  puts "\n7. List active locations:"
  active_locations = ServiceTrade::Location.active_locations
  puts "Found #{active_locations.length} active locations"

  # Search locations by company
  puts "\n8. Search locations by company:"
  company_locations = ServiceTrade::Location.by_company(123)
  puts "Found #{company_locations.length} locations for company 123"

  # Search locations by region
  puts "\n9. Search locations by region:"
  region_locations = ServiceTrade::Location.by_region([456, 789])
  puts "Found #{region_locations.length} locations in specified regions"

  # Get assets at a location
  puts "\n10. Get assets at location:"
  assets = new_location.assets
  puts "Found #{assets.length} assets at location"
  assets.each { |asset| puts "  - #{asset['name']} (Type: #{asset['type']})" }

  # Get comments for a location
  puts "\n11. Get comments for location:"
  comments = new_location.comments
  puts "Found #{comments.length} comments for location"

  # Create a comment for the location
  puts "\n12. Add comment to location:"
  comment_result = new_location.create_comment(
    content: 'API test comment - location created via API',
    type: 'general'
  )
  puts "Added comment to location"

  # Search locations with tags
  puts "\n13. Search locations with tags:"
  tagged_locations = ServiceTrade::Location.with_tags(['important', 'priority'])
  puts "Found #{tagged_locations.length} locations with specified tags"

  # Search locations updated after a certain time
  puts "\n14. Search recently updated locations:"
  one_week_ago = (Time.now - 7 * 24 * 60 * 60).to_i
  recent_locations = ServiceTrade::Location.updated_after(one_week_ago)
  puts "Found #{recent_locations.length} locations updated in the last week"

  # Using status convenience methods
  puts "\n15. Using status convenience methods:"
  puts "Location #{new_location.id} active?: #{new_location.active?}"
  puts "Location #{new_location.id} taxable?: #{new_location.taxable?}"

  # Merge locations (be careful with this one!)
  # puts "\n16. Merge location into another:"
  # merged_location = new_location.merge(456) # Replace with actual replacement ID
  # puts "Merged location #{new_location.id} into #{merged_location.id}"

  # Delete a location (be careful with this one!)
  # puts "\n17. Delete location:"
  # ServiceTrade::Location.delete(new_location.id)
  # puts "Deleted location #{new_location.id}"

rescue ServiceTrade::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
  puts "Please check your username and password"
rescue ServiceTrade::NotFoundError => e
  puts "Resource not found: #{e.message}"
  puts "Please check the ID you're trying to access"
rescue ServiceTrade::AuthorizationError => e
  puts "Authorization failed: #{e.message}"
  puts "You may not have permission to perform this action"
rescue ServiceTrade::ApiError => e
  puts "API error: #{e.message}"
rescue => e
  puts "Unexpected error: #{e.message}"
  puts "This might indicate a configuration or network issue"
end

puts "\n" + "=" * 40
puts "Example completed. Check the ServiceTrade dashboard to see created/modified locations."
puts "\nNote: Commented out destructive operations (merge/delete) for safety."