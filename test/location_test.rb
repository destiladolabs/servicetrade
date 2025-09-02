# frozen_string_literal: true

require_relative "test_helper"

class LocationTest < Test::Unit::TestCase
  def setup
    ServiceTrade.reset!
    ServiceTrade.configure do |config|
      config.username = "test_user"
      config.password = "test_password"
    end

    # Stub auth endpoint
    stub_request(:post, "https://api.servicetrade.com/api/auth")
      .with(
        body: '{"username":"test_user","password":"test_password"}',
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(
        status: 200,
        body: '{"sessionId":"test_session_123"}',
        headers: {'Content-Type' => 'application/json'}
      )
  end

  def test_location_resource_url
    assert_equal "location", ServiceTrade::Location.resource_url
  end

  def test_location_attributes_exist
    location = ServiceTrade::Location.new({
      'id' => 123,
      'name' => 'Test Location',
      'refNumber' => '123-REF',
      'lat' => 35.7796,
      'lon' => -78.6382,
      'status' => 'active',
      'taxable' => true,
      'phoneNumber' => '(555) 555-1234',
      'email' => 'test@example.com',
      'generalManager' => 'John Doe',
      'address' => {
        'street' => '123 Main St',
        'city' => 'Anytown',
        'state' => 'NC',
        'postalCode' => '27560'
      }
    })

    assert_equal 123, location.id
    assert_equal 'Test Location', location.name
    assert_equal '123-REF', location.ref_number
    assert_equal 35.7796, location.lat
    assert_equal -78.6382, location.lon
    assert_equal 'active', location.status
    assert_equal true, location.taxable
    assert_equal '(555) 555-1234', location.phone_number
    assert_equal 'test@example.com', location.email
    assert_equal 'John Doe', location.general_manager
    assert_equal({
      'street' => '123 Main St',
      'city' => 'Anytown',
      'state' => 'NC',
      'postalCode' => '27560'
    }, location.address)
  end

  def test_location_status_methods
    active_location = ServiceTrade::Location.new({'status' => 'active'})
    assert active_location.active?
    refute active_location.inactive?
    refute active_location.pending?
    refute active_location.on_hold?

    inactive_location = ServiceTrade::Location.new({'status' => 'inactive'})
    assert inactive_location.inactive?
    refute inactive_location.active?
    refute inactive_location.pending?
    refute inactive_location.on_hold?

    pending_location = ServiceTrade::Location.new({'status' => 'pending'})
    assert pending_location.pending?
    refute pending_location.active?
    refute pending_location.inactive?
    refute pending_location.on_hold?

    on_hold_location = ServiceTrade::Location.new({'status' => 'on_hold'})
    assert on_hold_location.on_hold?
    refute on_hold_location.active?
    refute on_hold_location.inactive?
    refute on_hold_location.pending?
  end

  def test_location_taxable_method
    taxable_location = ServiceTrade::Location.new({'taxable' => true})
    assert taxable_location.taxable?

    non_taxable_location = ServiceTrade::Location.new({'taxable' => false})
    refute non_taxable_location.taxable?
  end

  def test_full_address_method
    location = ServiceTrade::Location.new({
      'address' => {
        'street' => '123 Main St',
        'city' => 'Anytown',
        'state' => 'NC',
        'postalCode' => '27560'
      }
    })

    assert_equal '123 Main St, Anytown, NC, 27560', location.full_address

    # Test with individual address components
    location2 = ServiceTrade::Location.new({
      'addressStreet' => '456 Oak Ave',
      'addressCity' => 'Sometown',
      'addressState' => 'CA',
      'addressPostalCode' => '90210'
    })

    assert_equal '456 Oak Ave, Sometown, CA, 90210', location2.full_address

    # Test with no address
    location3 = ServiceTrade::Location.new({})
    assert_nil location3.full_address
  end

  def test_location_list_with_mocked_response
    response = {
      'data' => {
        'locations' => [
          {
            'id' => 123,
            'name' => 'Test Location 1',
            'status' => 'active',
            'lat' => 35.7796,
            'lon' => -78.6382
          },
          {
            'id' => 456,
            'name' => 'Test Location 2', 
            'status' => 'inactive',
            'lat' => 35.2271,
            'lon' => -80.8431
          }
        ],
        'total' => 2,
        'page' => 1
      }
    }

    stub_request(:get, /.*api\.servicetrade\.com\/api\/location.*/)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    locations = ServiceTrade::Location.list
    
    assert_equal 2, locations.length
    assert_equal 123, locations.first.id
    assert_equal 'Test Location 1', locations.first.name
    assert_equal 456, locations.last.id
    assert_equal 'Test Location 2', locations.last.name
  end

  def test_location_find_with_mocked_response
    response = {
      'data' => {
        'id' => 123,
        'name' => 'Test Location',
        'status' => 'active',
        'refNumber' => '123-REF',
        'phoneNumber' => '(555) 555-1234',
        'address' => {
          'street' => '123 Main St',
          'city' => 'Anytown',
          'state' => 'NC',
          'postalCode' => '27560'
        }
      }
    }

    stub_request(:get, "https://api.servicetrade.com/api/location/123")
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    location = ServiceTrade::Location.find(123)
    
    assert_equal 123, location.id
    assert_equal 'Test Location', location.name
    assert_equal 'active', location.status
    assert_equal '123-REF', location.ref_number
    assert_equal '(555) 555-1234', location.phone_number
  end

  def test_location_create_with_mocked_response
    request_params = {
      'companyId' => 30,
      'name' => 'New Location',
      'addressStreet' => '101 New St',
      'addressCity' => 'Newtown',
      'addressState' => 'NC',
      'addressPostalCode' => '27519',
      'officeIds' => [870]
    }

    response = {
      'data' => {
        'id' => 789,
        'name' => 'New Location',
        'refNumber' => '789',
        'status' => 'active',
        'address' => {
          'street' => '101 New St',
          'city' => 'Newtown',
          'state' => 'NC',
          'postalCode' => '27519'
        }
      }
    }

    stub_request(:post, "https://api.servicetrade.com/api/location")
      .with(body: request_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    location = ServiceTrade::Location.create(request_params)
    
    assert_equal 789, location.id
    assert_equal 'New Location', location.name
    assert_equal 'active', location.status
  end

  def test_location_update_with_mocked_response
    request_params = {
      'primaryContactId' => 14
    }

    response = {
      'data' => {
        'id' => 123,
        'name' => 'Updated Location',
        'status' => 'active',
        'primaryContact' => {
          'id' => 14,
          'firstName' => 'John',
          'lastName' => 'Doe'
        }
      }
    }

    stub_request(:put, "https://api.servicetrade.com/api/location/123")
      .with(body: request_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    location = ServiceTrade::Location.update(123, request_params)
    
    assert_equal 123, location.id
    assert_equal 'Updated Location', location.name
    assert_equal({'id' => 14, 'firstName' => 'John', 'lastName' => 'Doe'}, location.primary_contact)
  end

  def test_location_delete_with_mocked_response
    stub_request(:delete, "https://api.servicetrade.com/api/location/123")
      .to_return(status: 204)

    result = ServiceTrade::Location.delete(123)
    assert_equal true, result
  end

  def test_location_merge_with_mocked_response
    merge_params = { replacement_id: 456 }
    
    response = {
      'data' => {
        'id' => 456,
        'name' => 'Merged Location',
        'status' => 'active'
      }
    }

    stub_request(:post, "https://api.servicetrade.com/api/location/123/merge")
      .with(body: merge_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    location = ServiceTrade::Location.new({'id' => 123, 'name' => 'Original Location'})
    merged_location = location.merge(456)
    
    assert_equal 456, merged_location.id
    assert_equal 'Merged Location', merged_location.name
  end

  def test_location_assets_with_mocked_response
    response = {
      'data' => {
        'assets' => [
          {
            'id' => 1,
            'name' => 'Building',
            'type' => 'location'
          },
          {
            'id' => 27,
            'name' => 'Panic Door',
            'type' => 'panic_door'
          }
        ]
      }
    }

    stub_request(:get, "https://api.servicetrade.com/api/location/123/asset")
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    location = ServiceTrade::Location.new({'id' => 123})
    assets = location.assets
    
    assert_equal 2, assets.length
    assert_equal 1, assets.first['id']
    assert_equal 'Building', assets.first['name']
    assert_equal 27, assets.last['id']
    assert_equal 'Panic Door', assets.last['name']
  end

  def test_location_convenience_methods
    # Test filtering methods exist
    assert_respond_to ServiceTrade::Location, :by_name
    assert_respond_to ServiceTrade::Location, :by_company
    assert_respond_to ServiceTrade::Location, :by_ref_number
    assert_respond_to ServiceTrade::Location, :by_status
    assert_respond_to ServiceTrade::Location, :by_region
    assert_respond_to ServiceTrade::Location, :by_office
    assert_respond_to ServiceTrade::Location, :customers_only
    assert_respond_to ServiceTrade::Location, :vendors_only
    assert_respond_to ServiceTrade::Location, :active_locations
    assert_respond_to ServiceTrade::Location, :inactive_locations
    assert_respond_to ServiceTrade::Location, :updated_after
    assert_respond_to ServiceTrade::Location, :updated_before
    assert_respond_to ServiceTrade::Location, :created_after
    assert_respond_to ServiceTrade::Location, :created_before
    assert_respond_to ServiceTrade::Location, :with_tags
  end
end