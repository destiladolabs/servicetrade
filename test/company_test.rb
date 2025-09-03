# frozen_string_literal: true

require_relative "test_helper"

class CompanyTest < Test::Unit::TestCase
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

  def test_company_resource_url
    assert_equal "company", ServiceTrade::Company.resource_url
  end

  def test_company_attributes_exist
    company = ServiceTrade::Company.new({
      'id' => 123,
      'name' => 'Test Company',
      'status' => 'active',
      'uri' => '/api/company/123'
    })

    assert_equal 123, company.id
    assert_equal 'Test Company', company.name
    assert_equal 'active', company.status
    assert_equal '/api/company/123', company.uri
  end

  def test_company_status_methods
    company = ServiceTrade::Company.new({'status' => 'active'})
    assert company.active?
    refute company.inactive?
    refute company.pending?
    refute company.on_hold?

    company = ServiceTrade::Company.new({'status' => 'inactive'})
    assert company.inactive?
    refute company.active?
    refute company.pending?
    refute company.on_hold?

    company = ServiceTrade::Company.new({'status' => 'pending'})
    assert company.pending?
    refute company.active?
    refute company.inactive?
    refute company.on_hold?

    company = ServiceTrade::Company.new({'status' => 'on_hold'})
    assert company.on_hold?
    refute company.active?
    refute company.inactive?
    refute company.pending?
  end

  def test_company_list_with_mocked_response
    response = {
      'data' => {
        'companies' => [
          {
            'id' => 123,
            'name' => 'Test Company 1',
            'status' => 'active',
            'uri' => '/api/company/123'
          },
          {
            'id' => 456,
            'name' => 'Test Company 2', 
            'status' => 'inactive',
            'uri' => '/api/company/456'
          }
        ],
        'total' => 2,
        'page' => 1
      }
    }

    stub_request(:get, /.*api\.servicetrade\.com\/api\/company.*/)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    companies_response = ServiceTrade::Company.list
    
    assert_equal 2, companies_response.data.length
    assert_equal 123, companies_response.data.first.id
    assert_equal 'Test Company 1', companies_response.data.first.name
    assert_equal 456, companies_response.data.last.id
    assert_equal 'Test Company 2', companies_response.data.last.name
  end

  def test_company_find_with_mocked_response
    response = {
      'data' => {
        'id' => 123,
        'name' => 'Test Company',
        'status' => 'active',
        'uri' => '/api/company/123'
      }
    }

    stub_request(:get, "https://api.servicetrade.com/api/company/123")
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    company = ServiceTrade::Company.find(123)
    
    assert_equal 123, company.id
    assert_equal 'Test Company', company.name
    assert_equal 'active', company.status
    assert_equal '/api/company/123', company.uri
  end

  def test_company_create_with_mocked_response
    request_params = {
      'name' => 'New Company',
      'status' => 'active'
    }

    response = {
      'data' => {
        'id' => 789,
        'name' => 'New Company',
        'status' => 'active',
        'uri' => '/api/company/789'
      }
    }

    stub_request(:post, "https://api.servicetrade.com/api/company")
      .with(body: request_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    company = ServiceTrade::Company.create(request_params)
    
    assert_equal 789, company.id
    assert_equal 'New Company', company.name
    assert_equal 'active', company.status
  end

  def test_company_update_with_mocked_response
    request_params = {
      'name' => 'Updated Company',
      'status' => 'inactive'
    }

    response = {
      'data' => {
        'id' => 123,
        'name' => 'Updated Company',
        'status' => 'inactive',
        'uri' => '/api/company/123'
      }
    }

    stub_request(:put, "https://api.servicetrade.com/api/company/123")
      .with(body: request_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    company = ServiceTrade::Company.update(123, request_params)
    
    assert_equal 123, company.id
    assert_equal 'Updated Company', company.name
    assert_equal 'inactive', company.status
  end

  def test_company_delete_with_mocked_response
    stub_request(:delete, "https://api.servicetrade.com/api/company/123")
      .to_return(
        status: 200,
        body: '{}',
        headers: {'Content-Type' => 'application/json'}
      )

    result = ServiceTrade::Company.delete(123)
    assert_equal true, result
  end

  def test_company_instance_update
    company = ServiceTrade::Company.new({'id' => 123, 'name' => 'Test Company'})
    
    request_params = {'name' => 'Updated Company'}
    response = {
      'data' => {
        'id' => 123,
        'name' => 'Updated Company',
        'status' => 'active'
      }
    }

    stub_request(:put, "https://api.servicetrade.com/api/company/123")
      .with(body: request_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    updated_company = company.update(request_params)
    assert_equal 'Updated Company', updated_company.name
  end

  def test_company_instance_delete
    company = ServiceTrade::Company.new({'id' => 123, 'name' => 'Test Company'})
    
    stub_request(:delete, "https://api.servicetrade.com/api/company/123")
      .to_return(
        status: 200,
        body: '{}',
        headers: {'Content-Type' => 'application/json'}
      )

    result = company.delete
    assert_equal true, result
  end

  def test_company_convenience_methods
    # Test status filtering
    assert_respond_to ServiceTrade::Company, :by_status
  end
end