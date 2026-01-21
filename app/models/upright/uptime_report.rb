class Upright::UptimeReport
  attr_reader :site_code, :probe_type

  def initialize(site_code: nil, probe_type: "http")
    @site_code = site_code
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
      filters << "site_code=\"#{site_code}\"" if site_code.present?
      filters << "type=\"#{probe_type}\"" if probe_type.present?

      label_selector = filters.any? ? "{#{filters.join(',')}}" : ""

      if site_code.present?
        "avg_over_time(upright_probe_up#{label_selector}[1d:])"
      else
        "avg_over_time((avg by (name, type) (upright_probe_up#{label_selector}) >= 0.5)[1d:])"
      end
    end

    def prometheus_client
      Prometheus::ApiClient.client(
        url: ENV.fetch("PROMETHEUS_URL", "http://upright-prometheus:9090")
      )
    end
end
