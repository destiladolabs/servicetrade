class BaseResource
  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
    set_attributes(attributes)
  end

  private

  def set_attributes(attributes)
    attributes.each do |key, value|
      # Only set attributes that have corresponding reader methods
      if self.respond_to?(key)
        instance_variable_set("@#{key}", value)
      end
    end
  end
end