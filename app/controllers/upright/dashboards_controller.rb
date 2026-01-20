class Upright::DashboardsController < Upright::ApplicationController
  PROBE_TYPES = %w[http playwright smtp traceroute].freeze

  def uptime
    @sites = Upright.sites
    @probe_types = PROBE_TYPES
  end

  def status_codes
    @sites = Upright.sites
    @http_probe_names = Upright::Probes::HTTPProbe.all.map(&:probe_name).sort
  end
end
