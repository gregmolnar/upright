class Upright::DashboardsController < Upright::ApplicationController
  def uptime
    @probe_type = params.fetch(:probe_type, "http")
    @report = Upright::UptimeReport.new(probe_type: @probe_type)
  end
end
