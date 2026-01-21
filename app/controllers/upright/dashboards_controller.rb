class Upright::DashboardsController < Upright::ApplicationController
  def uptime
    @sites = Upright.sites
    @probe_type = params.fetch(:probe_type, "http")
    @report = Upright::UptimeReport.new(site_code: params[:site_code], probe_type: @probe_type)
  end
end
