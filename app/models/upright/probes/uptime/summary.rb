class Upright::Probes::Uptime::Summary
  include Comparable

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
    if daily_uptimes.empty?
      0
    else
      (daily_uptimes.values.sum / daily_uptimes.size) * 100
    end
  end

  def uptime_for_date(date)
    daily_uptimes[date.to_date]
  end

  def <=>(other)
    [ type, name ] <=> [ other.type, other.name ]
  end

  private
    def daily_uptimes
      @daily_uptimes ||= @result[:values].to_h { |timestamp, value| [ Time.at(timestamp).to_date, value.to_f ] }
    end
end
