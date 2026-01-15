module Upright::Traceroute::OtelTracing
  extend ActiveSupport::Concern

  private
    def tracer
      @tracer ||= OpenTelemetry.tracer_provider.tracer("upright.traceroute", "1.0.0")
    end

    def trace_result(result)
      tracer.in_span(root_span_name, attributes: root_span_attributes) do |root_span|
        logger.struct probe_trace_id: root_span.context.hex_trace_id if logger.respond_to?(:struct)

        result.hops.each_with_index do |hop, index|
          previous_hop = index > 0 ? result.hops[index - 1] : nil
          create_hop_span(hop, previous_hop)
        end

        root_span.status = if result.reached_destination?
          success_status
        else
          error_status("Failed to reach destination")
        end
      end
    end

    def create_hop_span(hop, previous_hop)
      previous_rtt_ms = previous_hop&.avg_ms.to_i
      current_rtt_ms = hop.avg_ms.to_i
      duration_ms = [ current_rtt_ms - previous_rtt_ms, 0 ].max

      tracer.in_span(hop.display_name, attributes: hop_span_attributes(hop, previous_hop)) do |span|
        span.status = hop_status(hop)
        sleep(duration_ms / 1000.0)
      end
    end

    def root_span_name
      "traceroute #{host}"
    end

    def hop_status(hop)
      if !hop.responded?
        error_status("No response")
      elsif hop.high_packet_loss?
        error_status("High packet loss: #{hop.loss_percent}%")
      elsif hop.any_packet_loss?
        success_status("Packet loss: #{hop.loss_percent}%")
      else
        success_status
      end
    end

    def success_status(message = nil)
      if message
        OpenTelemetry::Trace::Status.ok(message)
      else
        OpenTelemetry::Trace::Status.ok
      end
    end

    def error_status(message)
      OpenTelemetry::Trace::Status.error(message)
    end

    def root_span_attributes
      site = Upright.current_site
      {
        "traceroute.target" => host,
        "traceroute.max_hops" => self.class::MAX_HOPS,
        "traceroute.probe_count" => self.class::PROBE_COUNT,
        "upright.probe.name" => probe_name,
        "upright.probe.type" => probe_type,
        "upright.site.code" => site.code.to_s,
        "upright.site.city" => site.city.to_s,
        "upright.site.country" => site.country.to_s,
        "upright.site.geohash" => site.geohash.to_s,
        "upright.site.provider" => site.provider.to_s
      }.compact_blank
    end

    def hop_span_attributes(hop, previous_hop)
      {
        "traceroute.hop.number" => hop.number,
        "traceroute.hop.ip" => hop.ip,
        "traceroute.hop.hostname" => hop.hostname,
        "traceroute.hop.as" => hop.as,
        "traceroute.hop.isp" => hop.isp,
        "traceroute.hop.city" => hop.city,
        "traceroute.hop.country" => hop.country,
        "traceroute.hop.country_code" => hop.country_code,
        "traceroute.hop.geohash" => hop.geohash,
        "traceroute.hop.loss_percent" => hop.loss_percent,
        "traceroute.hop.rtt_last_ms" => hop.last_ms,
        "traceroute.hop.rtt_avg_ms" => hop.avg_ms,
        "traceroute.hop.rtt_best_ms" => hop.best_ms,
        "traceroute.hop.rtt_worst_ms" => hop.worst_ms,
        "traceroute.hop.rtt_stddev_ms" => hop.stddev_ms,
        "traceroute.hop.previous_ip" => previous_hop&.ip,
        "traceroute.hop.previous_isp" => previous_hop&.isp,
        "traceroute.hop.rtt_delta_ms" => rtt_delta_ms(hop, previous_hop)
      }.compact
    end

    def rtt_delta_ms(hop, previous_hop)
      delta = hop.avg_ms.to_i - previous_hop&.avg_ms.to_i
      [ delta, 0 ].max
    end
end
