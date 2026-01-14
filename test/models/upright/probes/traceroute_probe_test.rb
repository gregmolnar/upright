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

  test "stagger_delay is configured" do
    with_env("SITE_CODE" => "ams") do
      assert_equal 0.seconds, Upright::Probes::TracerouteProbe.stagger_delay
    end

    with_env("SITE_CODE" => "nyc") do
      assert_equal 3.seconds, Upright::Probes::TracerouteProbe.stagger_delay
    end
  end
end
