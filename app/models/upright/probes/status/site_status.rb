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
      sorted = @values.sort_by(&:first)
      down_start = sorted.last.first

      sorted.reverse_each do |timestamp, value|
        break if value.to_f == 1
        down_start = timestamp
      end

      Time.at(down_start)
    end
  end

  private
    def latest_value
      if @values.any?
        @values.max_by(&:first).last.to_f
      end
    end

    def latest_timestamp
      if @values.any?
        @values.max_by(&:first).first
      end
    end
end
