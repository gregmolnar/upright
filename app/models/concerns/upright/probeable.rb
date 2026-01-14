module Upright
  module Probeable
    extend ActiveSupport::Concern
    include Staggerable

    included do
      attr_writer :logger

      def logger
        @logger || Rails.logger
      end
    end

    class_methods do
      def check_and_record_all_later
        all.each(&:check_and_record_later)
      end
    end

    def perform_check
      # Overridden in subclasses that need setup around the actual check
      check
    end

    def check_and_record_later
      ProbeCheckJob.set(wait: self.class.stagger_delay).perform_later(self.class.name, name)
    end

    def check_and_record
      result = failsafe_check

      probe_result = ProbeResult.create! \
        probe_type: probe_type,
        probe_name: probe_name,
        probe_target: probe_target,
        probe_service: probe_service,
        status: result[:status],
        duration: result[:duration]

      on_check_recorded(probe_result)

      probe_result
    end

    def probe_name
      try(:name) || self.class.name.demodulize.underscore.delete_suffix("_probe")
    end

    def probe_type
      raise NotImplementedError
    end

    def probe_target
      raise NotImplementedError
    end

    def on_check_recorded(probe_result)
      # Optional hook for subclasses
    end

    def probe_service
      nil
    end

    private
      def failsafe_check
        result, error, duration = nil

        result, duration = measure { perform_check }
      rescue => error
        Rails.error.report(error)
        raise error if Rails.env.development?
      ensure
        log_probe_result(result:, error:, duration:)

        return { status: result_description(result, error), duration: }
      end

      def result_description(result, error = nil)
        if error
          :error
        else
          result ? :ok : :fail
        end
      end

      def measure
        start_time = monotonic_now
        result = yield
        [ result, monotonic_now - start_time ]
      end

      def monotonic_now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def log_probe_result(result:, error:, duration:)
        current_site = Upright.current_site

        log_data = {
          probe: {
            name: probe_name,
            target: probe_target,
            service: probe_service,
            type: probe_type,
            result: result_description(result, error),
            duration: duration,
            site_code: current_site.code,
            site_city: current_site.city,
            site_country: current_site.country,
            site_geohash: current_site.geohash,
            site_provider: current_site.provider
          }
        }

        if error
          log_data[:probe][:error_class] = error.class.name
          log_data[:probe][:error_message] = error.message
        end

        if logger.respond_to?(:struct)
          logger.struct(log_data)
        else
          logger.info(log_data.to_json)
        end
      end
  end
end
