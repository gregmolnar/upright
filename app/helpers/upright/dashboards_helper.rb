module Upright::DashboardsHelper
  def uptime_color_class(percentage)
    case percentage
    when 99.9..100 then "uptime-excellent"
    when 99..99.9  then "uptime-good"
    when 95..99    then "uptime-warning"
    else                "uptime-critical"
    end
  end

  def status_color_class(status_code)
    case status_code.to_i
    when 200..299 then "status-2xx"
    when 300..399 then "status-3xx"
    when 400..499 then "status-4xx"
    when 500..599 then "status-5xx"
    else               "status-unknown"
    end
  end

  def format_uptime_percentage(value)
    number_to_percentage(value, precision: 2)
  end
end
