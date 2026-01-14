module Upright
  module Tracing
    class << self
      def configure
        return unless defined?(OpenTelemetry)

        current_site = Upright.current_site

        OpenTelemetry::SDK.configure do |c|
          c.service_name = Upright.configuration.service_name
          c.service_version = Upright::VERSION

          c.resource = OpenTelemetry::SDK::Resources::Resource.create(
            "deployment.environment" => Rails.env,
            "site.code" => current_site&.code.to_s,
            "site.city" => current_site&.city.to_s,
            "site.country" => current_site&.country.to_s,
            "site.geohash" => current_site&.geohash.to_s,
            "site.provider" => current_site&.provider.to_s
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
        if defined?(OpenTelemetry)
          tracer.in_span(name, attributes: attributes, &block)
        else
          yield
        end
      end
    end
  end
end
