class Upright::Dashboards::UptimesController < Upright::ApplicationController
  def show
    @probe_type = params.fetch(:probe_type, :http)
    @probes = Upright::Probes::Uptime.for_type(@probe_type)
  end
end
