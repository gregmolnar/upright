require "test_helper"

class Upright::Probes::SMTPProbeTest < ActiveSupport::TestCase
  test "SMTP probes are configured" do
    assert Upright::Probes::SMTPProbe.count > 0

    probe = Upright::Probes::SMTPProbe.first
    assert probe.name.present?
    assert probe.host.present?
    assert_equal "smtp", probe.probe_type
    assert_equal probe.host, probe.probe_target
  end

  test "returns true when EHLO succeeds" do
    smtp = stub_smtp_client
    smtp.expects(:start).with("upright").yields(smtp)

    probe = Upright::Probes::SMTPProbe.new(name: "test", host: "mail.example.com")

    assert probe.check
  end

  test "returns false when EHLO fails" do
    smtp = stub_smtp_client
    smtp.expects(:start).with("upright").raises(Net::SMTPFatalError.new("550 Access denied"))

    probe = Upright::Probes::SMTPProbe.new(name: "test", host: "mail.example.com")

    assert_not probe.check
  end

  test "returns false when connection times out" do
    smtp = stub_smtp_client
    smtp.expects(:start).with("upright").raises(Net::OpenTimeout)

    probe = Upright::Probes::SMTPProbe.new(name: "test", host: "mail.example.com")

    assert_not probe.check
  end

  test "check_and_record attaches smtp log artifact" do
    set_test_site

    probe = Upright::Probes::SMTPProbe.new(name: "test", host: "mail.example.com")
    probe.logger = null_logger
    probe.stubs(:check).returns(true).tap do
      probe.smtp_log = StringIO.new("-> 220 mail.example.com ESMTP\n<- EHLO upright\n-> 250-OK\n")
    end

    probe.check_and_record

    result = Upright::ProbeResult.last
    assert_equal "ok", result.status
    assert_equal 1, result.artifacts.count
    assert_equal "smtp.log", result.artifacts.first.filename.to_s
  end

  test "stagger_delay is configured" do
    with_env("SITE_SUBDOMAIN" => "ams") do
      assert_equal 0.seconds, Upright::Probes::SMTPProbe.stagger_delay
    end

    with_env("SITE_SUBDOMAIN" => "nyc") do
      assert_equal 3.seconds, Upright::Probes::SMTPProbe.stagger_delay
    end
  end

  private
    def stub_smtp_client(host: "mail.example.com")
      mock.tap do |smtp|
        smtp.stubs(:open_timeout=)
        smtp.stubs(:read_timeout=)
        smtp.stubs(:debug_output=)
        Net::SMTP.expects(:new).with(host).returns(smtp)
      end
    end

    def null_logger
      Logger.new("/dev/null").tap do |l|
        l.define_singleton_method(:struct) { |_| }
      end
    end
end
