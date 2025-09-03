module ServiceTrade
  class Contact < BaseResource
    extend ServiceTrade::ApiOperations::Create
    extend ServiceTrade::ApiOperations::List
    extend ServiceTrade::ApiOperations::Update
    extend ServiceTrade::ApiOperations::Delete

    OBJECT_NAME = 'contact'.freeze

    # Core contact attributes
    attr_reader :id, :uri, :first_name, :last_name, :type, :types,
                :phone, :mobile, :alternate_phone, :email

    def self.resource_url
      OBJECT_NAME
    end

    # Find a specific contact by ID
    def self.find(id)
      response = ServiceTrade.client.request(:get, "#{resource_url}/#{id}")
      new(response['data'])
    end

    # Create a new contact
    def self.create(params = {})
      response = ServiceTrade.client.request(:post, resource_url, params)
      new(response['data'])
    end

    # Update an existing contact
    def self.update(id, params = {})
      response = ServiceTrade.client.request(:put, "#{resource_url}/#{id}", params)
      new(response['data'])
    end

    # Update this contact instance
    def update(params = {})
      self.class.update(id, params)
    end

    # Delete a contact
    def self.delete(id)
      ServiceTrade.client.request(:delete, "#{resource_url}/#{id}")
      true
    end

    # Delete this contact instance
    def delete
      self.class.delete(id)
    end

    # Convenience methods for common contact filtering
    def self.by_type(type, page: 1, per_page: 100)
      list({type: type}, page: page, per_page: per_page)
    end

    def self.by_email(email, page: 1, per_page: 100)
      list({email: email}, page: page, per_page: per_page)
    end

    def self.by_name(first_name: nil, last_name: nil, page: 1, per_page: 100)
      filters = {}
      filters[:first_name] = first_name if first_name
      filters[:last_name] = last_name if last_name
      list(filters, page: page, per_page: per_page)
    end

    # Get full name
    def full_name
      [first_name, last_name].compact.join(' ')
    end

    # Check if contact has phone number
    def has_phone?
      !phone.nil? && !phone.empty?
    end

    # Check if contact has mobile number
    def has_mobile?
      !mobile.nil? && !mobile.empty?
    end

    # Check if contact has email
    def has_email?
      !email.nil? && !email.empty?
    end

    # Get primary phone (mobile first, then phone)
    def primary_phone
      has_mobile? ? mobile : phone
    end

    # Check if contact has specific type
    def has_type?(type_name)
      return false unless types
      types.include?(type_name)
    end
  end
end