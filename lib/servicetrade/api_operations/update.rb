# frozen_string_literal: true

module ServiceTrade
  module ApiOperations
    module Update
      def update(id, params = {})
        response = ServiceTrade.client.request(:put, "#{resource_url}/#{id}", params)
        new(response['data'])
      end
    end
  end
end