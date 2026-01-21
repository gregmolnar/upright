class Upright::UptimeReport
  attr_reader :probe_type

  def initialize(probe_type: "http")
    @probe_type = probe_type
  end

  def probes
    @probes ||= fetch_probes
  end

  private
    def fetch_probes
      data = prometheus_client.query_range(
        query: query,
        start: 30.days.ago.iso8601,
        end: Time.current.iso8601,
        step: "86400s"
      ).deep_symbolize_keys

      data[:result].map { |result| Upright::UptimeProbe.new(result) }.sort_by { |p| [ p.type, p.name ] }
    end

    def query
      filters = []
      filters << "type=\"#{probe_type}\"" if probe_type.present?

      label_selector = filters.any? ? "{#{filters.join(',')}}" : ""

      # Uptime = percentage of time per day when majority of sites reported UP.
      # - down_fraction <= 0.5 means majority says UP, returns 1; otherwise 0
      # - Fallback to 1 (up) when down_fraction absent (no sites reported down)
      # - avg_over_time averages these 0/1 values over each day
      <<~PROMQL.squish
        avg_over_time((
          (upright:probe_down_fraction#{label_selector} <= bool 0.5)
          or
          (max by (name, type, probe_target) (upright_probe_up#{label_selector}) * 0 + 1)
        )[1d:])
      PROMQL
    end

    def prometheus_client
      Prometheus::ApiClient.client(
        url: ENV.fetch("PROMETHEUS_URL", "http://upright-prometheus:9090"),
        options: { timeout: 30 }
      )
    end
end
