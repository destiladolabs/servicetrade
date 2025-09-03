# frozen_string_literal: true

require_relative "test_helper"

class ContactTest < Test::Unit::TestCase
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
        body: '{"sessionId": "test_session_123", "data": {"authenticated": true, "authToken": "test_session_123", "user": {"id": 1, "username": "test_user"}}}',
        headers: {'Content-Type' => 'application/json'}
      )
  end

  def test_contact_resource_url
    assert_equal "contact", ServiceTrade::Contact.resource_url
  end

  def test_contact_attributes_exist
    contact = ServiceTrade::Contact.new({
      'id' => 123,
      'firstName' => 'John',
      'lastName' => 'Doe',
      'email' => 'john.doe@example.com',
      'phone' => '555-1234',
      'mobile' => '555-5678',
      'alternatePhone' => '555-9999',
      'type' => 'primary',
      'types' => ['primary', 'billing'],
      'uri' => '/api/contact/123'
    })

    assert_equal 123, contact.id
    assert_equal 'John', contact.first_name
    assert_equal 'Doe', contact.last_name
    assert_equal 'john.doe@example.com', contact.email
    assert_equal '555-1234', contact.phone
    assert_equal '555-5678', contact.mobile
    assert_equal '555-9999', contact.alternate_phone
    assert_equal 'primary', contact.type
    assert_equal ['primary', 'billing'], contact.types
    assert_equal '/api/contact/123', contact.uri
  end

  def test_contact_full_name
    contact = ServiceTrade::Contact.new({
      'firstName' => 'John',
      'lastName' => 'Doe'
    })
    assert_equal 'John Doe', contact.full_name

    contact = ServiceTrade::Contact.new({
      'firstName' => 'John'
    })
    assert_equal 'John', contact.full_name

    contact = ServiceTrade::Contact.new({
      'lastName' => 'Doe'
    })
    assert_equal 'Doe', contact.full_name
  end

  def test_contact_has_phone_methods
    contact = ServiceTrade::Contact.new({
      'phone' => '555-1234',
      'mobile' => '555-5678',
      'email' => 'john@example.com'
    })

    assert contact.has_phone?
    assert contact.has_mobile?
    assert contact.has_email?

    contact_no_phone = ServiceTrade::Contact.new({})
    refute contact_no_phone.has_phone?
    refute contact_no_phone.has_mobile?
    refute contact_no_phone.has_email?
  end

  def test_contact_primary_phone
    contact = ServiceTrade::Contact.new({
      'phone' => '555-1234',
      'mobile' => '555-5678'
    })
    assert_equal '555-5678', contact.primary_phone

    contact_no_mobile = ServiceTrade::Contact.new({
      'phone' => '555-1234'
    })
    assert_equal '555-1234', contact_no_mobile.primary_phone

    contact_no_phone = ServiceTrade::Contact.new({})
    assert_nil contact_no_phone.primary_phone
  end

  def test_contact_has_type
    contact = ServiceTrade::Contact.new({
      'types' => ['primary', 'billing', 'technical']
    })

    assert contact.has_type?('primary')
    assert contact.has_type?('billing')
    assert contact.has_type?('technical')
    refute contact.has_type?('admin')

    contact_no_types = ServiceTrade::Contact.new({})
    refute contact_no_types.has_type?('primary')
  end

  def test_contact_list_with_mocked_response
    response = {
      'data' => {
        'contacts' => [
          {
            'id' => 123,
            'firstName' => 'John',
            'lastName' => 'Doe',
            'email' => 'john@example.com',
            'type' => 'primary'
          },
          {
            'id' => 456,
            'firstName' => 'Jane',
            'lastName' => 'Smith',
            'email' => 'jane@example.com',
            'type' => 'billing'
          }
        ],
        'total' => 2,
        'page' => 1
      }
    }

    stub_request(:get, /.*api\.servicetrade\.com\/api\/contact.*/)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    contacts_response = ServiceTrade::Contact.list
    
    assert_equal 2, contacts_response.data.length
    assert_equal 123, contacts_response.data.first.id
    assert_equal 'John Doe', contacts_response.data.first.full_name
    assert_equal 456, contacts_response.data.last.id
    assert_equal 'Jane Smith', contacts_response.data.last.full_name
  end

  def test_contact_find_with_mocked_response
    response = {
      'data' => {
        'id' => 123,
        'firstName' => 'John',
        'lastName' => 'Doe',
        'email' => 'john@example.com',
        'phone' => '555-1234',
        'type' => 'primary'
      }
    }

    stub_request(:get, "https://api.servicetrade.com/api/contact/123")
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    contact = ServiceTrade::Contact.find(123)
    
    assert_equal 123, contact.id
    assert_equal 'John', contact.first_name
    assert_equal 'Doe', contact.last_name
    assert_equal 'john@example.com', contact.email
    assert_equal '555-1234', contact.phone
  end

  def test_contact_create_with_mocked_response
    request_params = {
      'firstName' => 'New',
      'lastName' => 'Contact',
      'email' => 'new@example.com',
      'phone' => '555-0000',
      'type' => 'primary'
    }

    response = {
      'data' => {
        'id' => 789,
        'firstName' => 'New',
        'lastName' => 'Contact',
        'email' => 'new@example.com',
        'phone' => '555-0000',
        'type' => 'primary'
      }
    }

    stub_request(:post, "https://api.servicetrade.com/api/contact")
      .with(body: request_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    contact = ServiceTrade::Contact.create(request_params)
    
    assert_equal 789, contact.id
    assert_equal 'New Contact', contact.full_name
    assert_equal 'new@example.com', contact.email
  end

  def test_contact_update_with_mocked_response
    request_params = {
      'firstName' => 'Updated',
      'lastName' => 'Contact',
      'email' => 'updated@example.com'
    }

    response = {
      'data' => {
        'id' => 123,
        'firstName' => 'Updated',
        'lastName' => 'Contact',
        'email' => 'updated@example.com',
        'type' => 'primary'
      }
    }

    stub_request(:put, "https://api.servicetrade.com/api/contact/123")
      .with(body: request_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    contact = ServiceTrade::Contact.update(123, request_params)
    
    assert_equal 123, contact.id
    assert_equal 'Updated Contact', contact.full_name
    assert_equal 'updated@example.com', contact.email
  end

  def test_contact_delete_with_mocked_response
    stub_request(:delete, "https://api.servicetrade.com/api/contact/123")
      .to_return(
        status: 200,
        body: '{}',
        headers: {'Content-Type' => 'application/json'}
      )

    result = ServiceTrade::Contact.delete(123)
    assert_equal true, result
  end

  def test_contact_instance_update
    contact = ServiceTrade::Contact.new({'id' => 123, 'firstName' => 'John'})
    
    request_params = {'firstName' => 'Updated John'}
    response = {
      'data' => {
        'id' => 123,
        'firstName' => 'Updated John',
        'lastName' => 'Doe'
      }
    }

    stub_request(:put, "https://api.servicetrade.com/api/contact/123")
      .with(body: request_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    updated_contact = contact.update(request_params)
    assert_equal 'Updated John', updated_contact.first_name
  end

  def test_contact_instance_delete
    contact = ServiceTrade::Contact.new({'id' => 123, 'firstName' => 'John'})
    
    stub_request(:delete, "https://api.servicetrade.com/api/contact/123")
      .to_return(
        status: 200,
        body: '{}',
        headers: {'Content-Type' => 'application/json'}
      )

    result = contact.delete
    assert_equal true, result
  end

  def test_contact_convenience_methods
    # Test filtering methods
    assert_respond_to ServiceTrade::Contact, :by_type
    assert_respond_to ServiceTrade::Contact, :by_email
    assert_respond_to ServiceTrade::Contact, :by_name
  end
end