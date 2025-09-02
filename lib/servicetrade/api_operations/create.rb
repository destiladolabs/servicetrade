# frozen_string_literal: true

module ServiceTrade
  module ApiOperations
    module Create
      def create(params = {})
        response = ServiceTrade.client.request(:post, resource_url, params)
        new(response['data'])
      end
    end
  end
end
