# frozen_string_literal: true

require_relative "test_helper"

class JobTest < Test::Unit::TestCase
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

  def test_job_resource_url
    assert_equal "job", ServiceTrade::Job.resource_url
  end

  def test_job_attributes_exist
    job = ServiceTrade::Job.new({
      'id' => 123,
      'name' => 'Test Job',
      'status' => 'scheduled',
      'customName' => 'Custom Name',
      'type' => 'repair'
    })

    assert_equal 123, job.id
    assert_equal 'Test Job', job.name
    assert_equal 'scheduled', job.status
    assert_equal 'Custom Name', job.custom_name
    assert_equal 'repair', job.type
  end

  def test_job_status_methods
    job = ServiceTrade::Job.new({'status' => 'completed'})
    assert job.completed?
    refute job.scheduled?
    refute job.canceled?

    job = ServiceTrade::Job.new({'status' => 'scheduled'})
    assert job.scheduled?
    refute job.completed?
    refute job.canceled?

    job = ServiceTrade::Job.new({'status' => 'canceled'})
    assert job.canceled?
    refute job.completed?
    refute job.scheduled?
  end

  def test_job_ivr_open_method
    job = ServiceTrade::Job.new({'ivrOpen' => true})
    assert job.ivr_open?

    job = ServiceTrade::Job.new({'ivrOpen' => false})
    refute job.ivr_open?
  end

  def test_job_list_with_mocked_response
    response = {
      'data' => {
        'jobs' => [
          {
            'id' => 123,
            'name' => 'Test Job 1',
            'status' => 'scheduled'
          },
          {
            'id' => 456,
            'name' => 'Test Job 2', 
            'status' => 'completed'
          }
        ],
        'total' => 2,
        'page' => 1
      }
    }

    stub_request(:get, /.*api\.servicetrade\.com\/api\/job.*/)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    jobs_response = ServiceTrade::Job.list
    
    assert_equal 2, jobs_response.data.length
    assert_equal 123, jobs_response.data.first.id
    assert_equal 'Test Job 1', jobs_response.data.first.name
    assert_equal 456, jobs_response.data.last.id
    assert_equal 'Test Job 2', jobs_response.data.last.name
  end

  def test_job_find_with_mocked_response
    response = {
      'data' => {
        'id' => 123,
        'name' => 'Test Job',
        'status' => 'scheduled',
        'description' => 'Test job description'
      }
    }

    stub_request(:get, "https://api.servicetrade.com/api/job/123")
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    job = ServiceTrade::Job.find(123)
    
    assert_equal 123, job.id
    assert_equal 'Test Job', job.name
    assert_equal 'scheduled', job.status
    assert_equal 'Test job description', job.description
  end

  def test_job_create_with_mocked_response
    request_params = {
      'customName' => 'New Job',
      'locationId' => 456,
      'type' => 'repair',
      'description' => 'New job description'
    }

    response = {
      'data' => {
        'id' => 789,
        'name' => 'New Job',
        'status' => 'new',
        'customName' => 'New Job',
        'type' => 'repair'
      }
    }

    stub_request(:post, "https://api.servicetrade.com/api/job")
      .with(body: request_params.to_json)
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {'Content-Type' => 'application/json'}
      )

    job = ServiceTrade::Job.create(request_params)
    
    assert_equal 789, job.id
    assert_equal 'New Job', job.name
    assert_equal 'new', job.status
  end

  def test_job_convenience_methods
    # Test status filtering
    assert_respond_to ServiceTrade::Job, :by_status
    assert_respond_to ServiceTrade::Job, :by_customer
    assert_respond_to ServiceTrade::Job, :by_vendor
    assert_respond_to ServiceTrade::Job, :by_location
    assert_respond_to ServiceTrade::Job, :by_owner
    assert_respond_to ServiceTrade::Job, :around_location
    assert_respond_to ServiceTrade::Job, :due_between
    assert_respond_to ServiceTrade::Job, :completed_between
  end
end