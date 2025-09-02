# frozen_string_literal: true

module ServiceTrade
  module ApiOperations
    module Delete
      def delete(id)
        ServiceTrade.client.request(:delete, "#{resource_url}/#{id}")
        true
      end
    end
  end
end