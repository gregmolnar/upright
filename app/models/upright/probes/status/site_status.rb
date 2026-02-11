class Upright::Probes::Status::SiteStatus
  STALE_THRESHOLD = 5.minutes

  attr_reader :site_code, :site_city

  def initialize(site_code:, site_city:, values:)
    @site_code = site_code
    @site_city = site_city
    @values = values
  end

  def up?
    latest_value == 1
  end

  def down?
    !up?
  end

  def stale?
    if @values.empty?
      true
    else
      Time.at(latest_timestamp) < STALE_THRESHOLD.ago
    end
  end

  def down_since
    if down? && @values.any?
      Time.at(down_start_timestamp)
    end
  end

  def down_since_known?
    if down? && @values.any?
      down_start_timestamp != sorted_values.first.first
    else
      false
    end
  end

  private
    def sorted_values
      @sorted_values ||= @values.sort_by(&:first)
    end

    def down_start_timestamp
      @down_start_timestamp ||= begin
        result = sorted_values.last.first

        sorted_values.reverse_each do |timestamp, value|
          break if value.to_f == 1
          result = timestamp
        end

        result
      end
    end

    def latest_value
      if @values.any?
        sorted_values.last.last.to_f
      end
    end

    def latest_timestamp
      if @values.any?
        sorted_values.last.first
      end
    end
end
