module ServiceTrade
  class Region < BaseResource
    extend ServiceTrade::ApiOperations::Create
    extend ServiceTrade::ApiOperations::List
    extend ServiceTrade::ApiOperations::Update
    extend ServiceTrade::ApiOperations::Delete

    OBJECT_NAME = 'region'.freeze

    # Core region attributes
    attr_reader :id, :uri, :name, :color, :points, :offices

    def self.resource_url
      OBJECT_NAME
    end

    # Find a specific region by ID
    def self.find(id)
      response = ServiceTrade.client.request(:get, "#{resource_url}/#{id}")
      new(response['data'])
    end

    # Enhanced list method with comprehensive filtering and pagination
    def self.list(filters = {}, page: 1, per_page: 100)
      # Use the pagination from the List module
      super(filters, page: page, per_page: per_page)
    end

    # Create a new region
    def self.create(params = {})
      response = ServiceTrade.client.request(:post, resource_url, params)
      new(response['data'])
    end

    # Update an existing region
    def self.update(id, params = {})
      response = ServiceTrade.client.request(:put, "#{resource_url}/#{id}", params)
      new(response['data'])
    end

    # Update this region instance
    def update(params = {})
      self.class.update(id, params)
    end

    # Delete a region
    def self.delete(id)
      ServiceTrade.client.request(:delete, "#{resource_url}/#{id}")
      true
    end

    # Delete this region instance
    def delete
      self.class.delete(id)
    end

    # Clear and recalculate which locations are within this region
    def clear_cache
      ServiceTrade.client.request(:delete, "#{self.class.resource_url}/#{id}/cache")
      true
    end

    # Convenience methods for common region filtering
    def self.by_name(name, page: 1, per_page: 100)
      list({name: name}, page: page, per_page: per_page)
    end

    def self.by_office(office_ids, page: 1, per_page: 100)
      office_ids = Array(office_ids).join(',') if office_ids.is_a?(Array)
      list({officeIds: office_ids}, page: page, per_page: per_page)
    end

    def self.containing_point(lat, lon, page: 1, per_page: 100)
      list({contains: {lat: lat, lon: lon}}, page: page, per_page: per_page)
    end

    # Check if this region contains a given point
    def contains_point?(lat, lon)
      # Simple point-in-polygon test using ray casting algorithm
      return false if points.nil? || points.empty?

      x, y = lon, lat
      inside = false

      j = points.length - 1
      (0...points.length).each do |i|
        xi, yi = points[i][1], points[i][0]  # lon, lat
        xj, yj = points[j][1], points[j][0]  # lon, lat

        # Check if point is on polygon boundary
        if ((yi <= y && y < yj) || (yj <= y && y < yi)) &&
           (x < (xj - xi) * (y - yi) / (yj - yi) + xi)
          inside = !inside
        end
        j = i
      end

      inside
    end

    # Get the bounding box of this region
    def bounding_box
      return nil if points.nil? || points.empty?

      min_lat = points.map(&:first).min
      max_lat = points.map(&:first).max
      min_lon = points.map(&:last).min
      max_lon = points.map(&:last).max

      {
        min_lat: min_lat,
        max_lat: max_lat,
        min_lon: min_lon,
        max_lon: max_lon
      }
    end

    # Get the approximate center point of this region
    def center_point
      return nil if points.nil? || points.empty?

      total_lat = points.map(&:first).sum
      total_lon = points.map(&:last).sum
      count = points.length

      [total_lat / count, total_lon / count]
    end

    # Check if region has a color assigned
    def has_color?
      !color.nil? && !color.empty?
    end

    # Check if region has offices assigned
    def has_offices?
      offices && !offices.empty?
    end
  end
end