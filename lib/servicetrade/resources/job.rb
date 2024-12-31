module ServiceTrade
  class Job < BaseResource
    extend ServiceTrade::ApiOperations::Create
    extend ServiceTrade::ApiOperations::List
    extend ServiceTrade::ApiOperations::Update
    extend ServiceTrade::ApiOperations::Delete

    OBJECT_NAME = 'jobs'.freeze

    attr_reader :id, :name, :status, :customer_id, :location_id,
    :scheduled_date, :completed_date, :created_at, :updated_at

    def self.resource_url
      OBJECT_NAME
    end
  end
end