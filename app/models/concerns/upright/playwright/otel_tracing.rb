module Upright::Playwright::OtelTracing
  extend ActiveSupport::Concern

  included do
    set_callback :perform_check, :around, :with_resource_tracing
  end

  def with_resource_tracing(&block)
    return block.call unless defined?(OpenTelemetry)

    collected_responses = []

    page.on("response", ->(response) {
      unless skip_span?(response)
        collected_responses << response
      end
    })

    trace_check_with_responses(collected_responses, &block)
  end

  private
    SKIP_URL_PATTERNS = %w[ image asset avatar ]

    def tracer
      @tracer ||= OpenTelemetry.tracer_provider.tracer(
        Upright.configuration.service_name,
        Upright::VERSION
      )
    end

    def skip_span?(response)
      SKIP_URL_PATTERNS.any? { |skip_pattern| response.url.include?(skip_pattern) || response.request.resource_type == skip_pattern }
    end

    def trace_check_with_responses(collected_responses, &block)
      tracer.in_span(:probe, attributes: root_span_attributes) do |span|
        result = block.call
        create_response_spans_for(collected_responses)
        result
      end
    end

    def root_span_attributes
      {
        "probe.name" => self.class.name
      }
    end

    def create_response_spans_for(collected_responses)
      collected_responses.each do |response|
        create_response_span(response)
      end
    end

    def create_response_span(response)
      span_time_range = calculate_span_timestamps(response.request.timing)
      span_name = "#{response.request.resource_type} #{extract_path(response.url)}"

      span = tracer.start_span(
        span_name,
        kind: :client,
        start_timestamp: span_time_range.begin,
        attributes: response_span_attributes(response)
      )

      span.status = map_http_status_to_otel(response.status)
      span.set_attribute("error", true) if response.status >= 400
      add_browser_performance_metrics_to_span(span) if response.request.resource_type == "document"
      span.finish(end_timestamp: span_time_range.end)
    end

    def calculate_span_timestamps(timing)
      start_timestamp_seconds = timing[:startTime] / 1000.0
      end_timestamp_seconds = (timing[:startTime] + timing[:responseEnd]) / 1000.0
      start_timestamp_seconds..end_timestamp_seconds
    end

    def extract_path(url)
      uri = URI.parse(url)
      path = uri.path.presence || "/"
      path += "?#{uri.query}" if uri.query.present?
      path
    end

    def response_span_attributes(response)
      {
        "http.url" => response.url,
        "http.status_code" => response.status,
        "http.resource_type" => response.request.resource_type,
        "http.timing.time_to_first_byte" => calculate_time_to_first_byte(response.request.timing),
        "http.timing.total" => calculate_total_time(response.request.timing),
        "http.request.size" => response.request.sizes[:requestBodySize],
        "http.response.size" => response.request.sizes[:responseBodySize],
        "http.response.header.x_runtime" => response.headers["x-runtime"].to_f,
        "http.response.header.x_request_id" => response.headers["x-request-id"],
        "http.response.header.server_timing" => response.headers["server-timing"]
      }.compact
    end

    def calculate_time_to_first_byte(timing)
      (timing[:responseStart] - timing[:requestStart]).round(2)
    end

    def calculate_total_time(timing)
      (timing[:responseEnd] - timing[:requestStart]).round(2)
    end

    def map_http_status_to_otel(http_status)
      case http_status
      when 200..299
        OpenTelemetry::Trace::Status.ok
      when 400..599
        OpenTelemetry::Trace::Status.error("HTTP #{http_status}")
      else
        OpenTelemetry::Trace::Status.unset
      end
    end

    def add_browser_performance_metrics_to_span(span)
      metrics = collect_browser_performance_metrics

      metrics.each do |key, value|
        span.set_attribute("browser.performance.#{key}", value) if value
      end
    end

    def collect_browser_performance_metrics
      page.evaluate(performance_metrics_script)
    end

    def performance_metrics_script
      @performance_metrics_script ||= File.read(
        Upright::Engine.root.join("lib", "upright", "playwright", "collect_performance_metrics.js")
      )
    end
end
