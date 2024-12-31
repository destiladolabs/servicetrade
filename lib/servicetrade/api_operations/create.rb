# frozen_string_literal: true

module ServiceTrade
  module APIOperations
    module Create
      def create(params = {})
        response = @client.post(resource_url, params)
        convert_to_servicetrade_object(response)
      end
    end
  end
end
