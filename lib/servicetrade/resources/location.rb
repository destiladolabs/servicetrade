module ServiceTrade
  class Location < BaseResource
    extend ServiceTrade::ApiOperations::Create
    extend ServiceTrade::ApiOperations::List
    extend ServiceTrade::ApiOperations::Update
    extend ServiceTrade::ApiOperations::Delete

    OBJECT_NAME = 'location'.freeze

    # Core location attributes
    attr_reader :id, :uri, :name, :ref_number, :lat, :lon, :geocode_quality,
                :distance, :phone_number, :email, :general_manager, :status,
                :taxable, :store_number, :created, :updated

    # Address components
    attr_reader :address, :address_street, :address_city, :address_state, :address_postal_code

    # Related objects
    attr_reader :company, :brand, :primary_contact, :offices, :tags, :tax_group,
                :external_ids, :remit_to_address, :remit_to_source

    # Deprecated fields (kept for backwards compatibility)
    attr_reader :legacy_id

    def self.resource_url
      OBJECT_NAME
    end

    # Find a specific location by ID
    def self.find(id)
      response = ServiceTrade.client.request(:get, "#{resource_url}/#{id}")
      new(response['data'])
    end

    # Enhanced list method with comprehensive filtering
    def self.list(filters = {})
      # Set default isCustomer to true if not specified
      unless filters.key?(:is_customer) || filters.key?('isCustomer')
        filters[:is_customer] = true
      end

      response = ServiceTrade.client.request(:get, resource_url, filters)
      
      # Handle the nested response structure from ServiceTrade API
      locations_data = response.dig('data', 'locations') || response['data'] || []
      locations_data.map { |location_data| new(location_data) }
    end

    # Create a new location
    def self.create(params = {})
      response = ServiceTrade.client.request(:post, resource_url, params)
      new(response['data'])
    end

    # Update an existing location
    def self.update(id, params = {})
      response = ServiceTrade.client.request(:put, "#{resource_url}/#{id}", params)
      new(response['data'])
    end

    # Update this location instance
    def update(params = {})
      self.class.update(id, params)
    end

    # Delete a location
    def self.delete(id)
      ServiceTrade.client.request(:delete, "#{resource_url}/#{id}")
      true
    end

    # Delete this location instance
    def delete
      self.class.delete(id)
    end

    # Merge this location into another location
    def merge(replacement_id)
      params = { replacement_id: replacement_id }
      response = ServiceTrade.client.request(:post, "#{self.class.resource_url}/#{id}/merge", params)
      self.class.new(response['data'])
    end

    # Get assets at this location
    def assets
      response = ServiceTrade.client.request(:get, "#{self.class.resource_url}/#{id}/asset")
      assets_data = response.dig('data', 'assets') || []
      # For now, return raw data - could create Asset resource class later
      assets_data
    end

    # Get comments for this location
    def comments
      response = ServiceTrade.client.request(:get, "#{self.class.resource_url}/#{id}/comment")
      comments_data = response.dig('data', 'comments') || []
      # For now, return raw data - could create Comment resource class later
      comments_data
    end

    # Create a comment for this location
    def create_comment(params = {})
      response = ServiceTrade.client.request(:post, "#{self.class.resource_url}/#{id}/comment", params)
      response['data']
    end

    # Convenience methods for common location filtering
    def self.by_name(name)
      list(name: name)
    end

    def self.by_company(company_id)
      list(company_id: company_id)
    end

    def self.by_ref_number(ref_number)
      list(ref_number: ref_number)
    end

    def self.by_status(status)
      list(status: status)
    end

    def self.by_region(region_ids)
      region_ids = Array(region_ids).join(',') if region_ids.is_a?(Array)
      list(region_ids: region_ids)
    end

    def self.by_office(office_ids)
      office_ids = Array(office_ids).join(',') if office_ids.is_a?(Array)
      list(office_ids: office_ids)
    end

    def self.customers_only
      list(is_customer: true)
    end

    def self.vendors_only
      list(is_vendor: true)
    end

    def self.active_locations
      list(status: 'active')
    end

    def self.inactive_locations
      list(status: 'inactive')
    end

    def self.updated_after(timestamp)
      list(updated_after: timestamp)
    end

    def self.updated_before(timestamp)
      list(updated_before: timestamp)
    end

    def self.created_after(timestamp)
      list(created_after: timestamp)
    end

    def self.created_before(timestamp)
      list(created_before: timestamp)
    end

    def self.with_tags(tags)
      tags = Array(tags).join(',') if tags.is_a?(Array)
      list(tag: tags)
    end

    # Status check methods
    def active?
      status == 'active'
    end

    def inactive?
      status == 'inactive'
    end

    def pending?
      status == 'pending'
    end

    def on_hold?
      status == 'on_hold'
    end

    # Check if location is taxable
    def taxable?
      taxable == true
    end

    # Get the full address as a string
    def full_address
      parts = []
      
      if address
        parts = [
          address['street'],
          address['city'],
          address['state'],
          address['postalCode']
        ]
      else
        parts = [
          address_street,
          address_city,
          address_state,
          address_postal_code
        ]
      end
      
      parts = parts.compact
      return nil if parts.empty?
      
      parts.join(', ')
    end
  end
end