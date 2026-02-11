class Upright::Dashboards::ProbeStatusesController < Upright::ApplicationController
  def show
    @probe_type = params.fetch(:probe_type, :http)
    @probes = Upright::Probes::Status.for_type(@probe_type)
    @sites = Upright.sites
  end
end
