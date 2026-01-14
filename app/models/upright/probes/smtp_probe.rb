require "net/smtp"

module Upright
  module Probes
    class SMTPProbe < FrozenRecord::Base
      include Probeable

      stagger_by_site 3.seconds

      self.base_path = -> { Upright.configuration.frozen_record_path }
      self.backend = FrozenRecord::Backends::Yaml

      attr_accessor :smtp_log

      def check
        self.smtp_log = StringIO.new

        current_site = Upright.current_site

        smtp = Net::SMTP.new(host)
        smtp.open_timeout = current_site.default_timeout
        smtp.read_timeout = current_site.default_timeout
        smtp.debug_output = smtp_log

        smtp.start("upright") { }

        true
      rescue Net::SMTPError, Net::OpenTimeout, Net::ReadTimeout
        false
      end

      def on_check_recorded(probe_result)
        attach_log(probe_result)
      end

      def probe_type = "smtp"
      def probe_target = host

      private
        def attach_log(probe_result)
          if smtp_log
            smtp_log.rewind
            log_content = smtp_log.read

            if log_content.present?
              logger.debug { log_content }

              Artifact.new(name: "smtp.log", content: log_content).attach_to(probe_result)
            end
          end
        end
    end
  end
end
