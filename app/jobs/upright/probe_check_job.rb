module Upright
  class ProbeCheckJob < ApplicationJob
    MAX_ATTEMPTS = 2
    RETRY_DELAY = 5.seconds

    before_enqueue { self.scheduled_at = stagger_delay.from_now }
    before_perform :discard_if_stale
    around_perform { |job, block| Timeout.timeout(3.minutes, &block) }

    def perform(klass, name = nil)
      result = probe.check_and_record

      if !result.ok? && executions < MAX_ATTEMPTS
        retry_job(wait: RETRY_DELAY)
      end
    end

    private
      def stagger_delay
        arguments[0].constantize.stagger_delay
      end

      def discard_if_stale
        if scheduled_at && scheduled_at < 5.minutes.ago
          logger.info "Discarding stale probe job scheduled at #{scheduled_at}"
          throw :abort
        end
      end

      def probe
        klass = self.arguments[0].constantize

        instance = if klass < FrozenRecord::Base
          klass.find_by(name: self.arguments[1])
        else
          klass.new
        end

        instance.logger = logger

        instance
      end
  end
end
