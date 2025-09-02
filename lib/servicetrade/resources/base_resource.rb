module ServiceTrade
  class BaseResource
    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes
      set_attributes(attributes)
    end

    private

    def set_attributes(attributes)
      attributes.each do |key, value|
        # Convert camelCase to snake_case for Ruby conventions
        snake_key = camel_to_snake(key.to_s)
        
        # Only set attributes that have corresponding reader methods
        if self.respond_to?(snake_key)
          instance_variable_set("@#{snake_key}", value)
        end
      end
    end

    def camel_to_snake(str)
      str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .downcase
    end
  end
end