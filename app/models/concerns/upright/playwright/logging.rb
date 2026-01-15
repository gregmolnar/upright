module Upright::Playwright::Logging
  extend ActiveSupport::Concern

  included do
    attr_reader :log_lines

    set_callback :perform_check, :before, :start_resource_logging
    set_callback :perform_check, :after, :log_performance_metrics
  end

  def start_resource_logging
    @log_lines = []

    # Use structured logging if available, otherwise just log normally
    if defined?(RailsStructuredLogging::Recorder)
      RailsStructuredLogging::Recorder.instance.messages.tap do |messages|
        page.on("response", ->(response) {
          next if skip_logging?(response)
          RailsStructuredLogging::Recorder.instance.sharing(messages)
          log_response(response)
        })
      end
    else
      page.on("response", ->(response) {
        next if skip_logging?(response)
        log_response(response)
      })
    end
  end

  def log_response(response)
    headers = response.headers.slice("x-request-id", "x-runtime", "x-ratelimit-limit", "x-ratelimit-remaining").compact.map { |k, v| "#{k}=#{v}" }.join(" ")
    "#{response.status} #{response.request.resource_type.upcase} #{response.url} #{headers}".strip.tap do |line|
      log_lines << line
      Rails.logger.info line
    end
  end

  def log_performance_metrics
    current_site = Upright.current_site

    log_metrics url: page.url,
      total_resource_bytes: fetch_total_resource_bytes,
      total_load_ms: fetch_total_load_ms,
      site_code: current_site.code,
      site_city: current_site.city,
      site_country: current_site.country,
      site_geohash: current_site.geohash
  end

  def log_metrics(**metrics)
    if logger.respond_to?(:struct)
      logger.struct probe: metrics
    else
      logger.info metrics.to_json
    end
  end

  def fetch_total_resource_bytes
    page.evaluate <<~JS
      performance.getEntriesByType("resource").reduce((size, item) => {
        size += item.decodedBodySize;
        return size;
      }, 0);
    JS
  end

  def fetch_total_load_ms
    page.evaluate <<~JS
      const perfEntries = performance.getEntriesByType("navigation")
      perfEntries[0].loadEventEnd - perfEntries[0].startTime;
    JS
  end

  def attach_log(probe_result)
    if log_lines&.any?
      Upright::Artifact.new(name: "#{probe_name}.log", content: log_lines.join("\n")).attach_to(probe_result, timestamped: true)
    end
  end

  private
    SKIP_URL_PATTERNS = %w[ image asset avatar ]

    def skip_logging?(response)
      SKIP_URL_PATTERNS.any? { |skip_pattern| response.url.include?(skip_pattern) }
    end
end
