module Upright::DashboardsHelper
  def date_range
    (29.days.ago.to_date..Date.current).to_a
  end

  def uptime_bar_class(percentage)
    case percentage
    when 100      then "uptime-bar--perfect"
    when 99..100  then "uptime-bar--good"
    when 95..99   then "uptime-bar--warning"
    when 0.01..95 then "uptime-bar--critical"
    else               "uptime-bar--down"
    end
  end

  def uptime_color_class(percentage)
    case percentage
    when 99.9..100 then "uptime-excellent"
    when 99..99.9  then "uptime-good"
    when 95..99    then "uptime-warning"
    else                "uptime-critical"
    end
  end

  def uptime_bar_tooltip(date, uptime_percent, downtime_minutes)
    tooltip = "#{date.strftime('%b %-d')}: #{number_with_precision(uptime_percent, precision: 1)}% uptime"
    tooltip += " (#{format_downtime(downtime_minutes)} down)" if downtime_minutes > 0
    tooltip
  end

  def format_downtime(minutes)
    if minutes < 60
      "#{minutes}m"
    else
      hours = minutes / 60
      mins = minutes % 60
      mins.zero? ? "#{hours}h" : "#{hours}h #{mins}m"
    end
  end
end
