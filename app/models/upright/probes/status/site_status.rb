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
    return true if @values.empty?
    Time.at(latest_timestamp) < STALE_THRESHOLD.ago
  end

  def down_since
    return nil unless down?
    return nil if @values.empty?

    # Walk backwards to find when the continuous run of 0s started
    sorted = @values.sort_by(&:first)
    down_start = sorted.last.first

    sorted.reverse_each do |timestamp, value|
      break if value.to_f == 1
      down_start = timestamp
    end

    Time.at(down_start)
  end

  private
    def latest_value
      return nil if @values.empty?
      @values.max_by(&:first).last.to_f
    end

    def latest_timestamp
      return nil if @values.empty?
      @values.max_by(&:first).first
    end
end
