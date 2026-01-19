require "test_helper"
require "webmock/minitest"

class Upright::Probes::TracerouteProbeTest < ActiveSupport::TestCase
  setup do
    Upright::Traceroute::IpMetadataLookup.clear_cache
  end

  test "traceroute probe is configured" do
    assert_equal 2, Upright::Probes::TracerouteProbe.count

    probe = Upright::Probes::TracerouteProbe.find_by(name: "Google DNS")
    assert_equal "8.8.8.8", probe.host
    assert_equal "traceroute", probe.probe_type
    assert_equal "8.8.8.8", probe.probe_target
  end

  test "running a traceroute probe" do
    WebMock.allow_net_connect!
    stub_ip_api_batch
    with_env("SITE_SUBDOMAIN" => "ams") do
      probe = Upright::Probes::TracerouteProbe.first

      result = probe.check

      assert_includes [ true, false ], result
    end
  end

  test "check_and_record creates a probe result" do
    WebMock.allow_net_connect!
    stub_ip_api_batch
    with_env("SITE_SUBDOMAIN" => "ams") do
      probe = Upright::Probes::TracerouteProbe.first

      assert_difference "Upright::ProbeResult.count", 1 do
        probe.check_and_record
      end

      result = Upright::ProbeResult.last
      assert_equal "traceroute", result.probe_type
      assert_equal "Google DNS", result.probe_name
      assert_equal "8.8.8.8", result.probe_target
    end
  end

  test "stagger_delay is configured" do
    with_env("SITE_SUBDOMAIN" => "ams") do
      assert_equal 0.seconds, Upright::Probes::TracerouteProbe.stagger_delay
    end

    with_env("SITE_SUBDOMAIN" => "nyc") do
      assert_equal 3.seconds, Upright::Probes::TracerouteProbe.stagger_delay
    end
  end
end
