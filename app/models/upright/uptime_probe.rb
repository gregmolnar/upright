class Upright::UptimeProbe
  def initialize(result)
    @result = result
  end

  def name
    @result[:metric][:name]
  end

  def type
    @result[:metric][:type]
  end

  def overall_uptime
    return 0 if daily_uptimes.empty?

    (daily_uptimes.values.sum / daily_uptimes.size) * 100
  end

  def uptime_for_date(date)
    daily_uptimes[date.to_date]
  end

  private
    def daily_uptimes
      @daily_uptimes ||= @result[:values].to_h { |timestamp, value| [Time.at(timestamp).to_date, value.to_f] }
    end
end
