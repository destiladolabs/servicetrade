module ServiceTrade
  class Company < BaseResource
    extend ServiceTrade::ApiOperations::Create
    extend ServiceTrade::ApiOperations::List
    extend ServiceTrade::ApiOperations::Update
    extend ServiceTrade::ApiOperations::Delete

    OBJECT_NAME = 'company'.freeze

    # Core company attributes
    attr_reader :id, :uri, :name, :status

    def self.resource_url
      OBJECT_NAME
    end

    # Find a specific company by ID
    def self.find(id)
      response = ServiceTrade.client.request(:get, "#{resource_url}/#{id}")
      new(response['data'])
    end

    # Create a new company
    def self.create(params = {})
      response = ServiceTrade.client.request(:post, resource_url, params)
      new(response['data'])
    end

    # Update an existing company
    def self.update(id, params = {})
      response = ServiceTrade.client.request(:put, "#{resource_url}/#{id}", params)
      new(response['data'])
    end

    # Update this company instance
    def update(params = {})
      self.class.update(id, params)
    end

    # Delete a company
    def self.delete(id)
      ServiceTrade.client.request(:delete, "#{resource_url}/#{id}")
      true
    end

    # Delete this company instance
    def delete
      self.class.delete(id)
    end

    # Convenience methods for common company filtering
    def self.by_status(status, page: 1, per_page: 100)
      list({status: status}, page: page, per_page: per_page)
    end

    # Check if company is active
    def active?
      status == 'active'
    end

    # Check if company is inactive
    def inactive?
      status == 'inactive'
    end

    # Check if company is pending
    def pending?
      status == 'pending'
    end

    # Check if company is on hold
    def on_hold?
      status == 'on_hold'
    end
  end
end