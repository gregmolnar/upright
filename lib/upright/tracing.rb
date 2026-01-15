module Upright::Tracing
  class << self
    def configure
      current_site = Upright.current_site

      OpenTelemetry::SDK.configure do |c|
        c.service_name = Upright.configuration.service_name
        c.service_version = Upright::VERSION

        c.resource = OpenTelemetry::SDK::Resources::Resource.create(
          resource_attributes(current_site)
        )

        # Use OTLP exporter if endpoint is configured
        if Upright.configuration.otel_endpoint
          c.add_span_processor(
            OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
              OpenTelemetry::Exporter::OTLP::Exporter.new(
                endpoint: Upright.configuration.otel_endpoint
              )
            )
          )
        end

        c.use_all
      end
    end

    def tracer
      OpenTelemetry.tracer_provider.tracer(Upright.configuration.service_name, Upright::VERSION)
    end

    def with_span(name, attributes: {}, &block)
      tracer.in_span(name, attributes: attributes, &block)
    end

    private
      def resource_attributes(site)
        {
          "deployment.environment" => Rails.env.to_s,
          "site.code" => site.code.to_s,
          "site.city" => site.city.to_s,
          "site.country" => site.country.to_s,
          "site.geohash" => site.geohash.to_s,
          "site.provider" => site.provider.to_s
        }.compact_blank
      end
  end
end
