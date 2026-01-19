require "net/smtp"

class Upright::Probes::SMTPProbe < FrozenRecord::Base
  include Upright::Probeable
  include Upright::ProbeYamlSource

  stagger_by_site 3.seconds

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

          Upright::Artifact.new(name: "smtp.log", content: log_content).attach_to(probe_result)
        end
      end
    end
end
