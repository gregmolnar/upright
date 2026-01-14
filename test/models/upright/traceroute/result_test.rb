require "test_helper"
require "webmock/minitest"

class Upright::Traceroute::ResultTest < ActiveSupport::TestCase
  setup do
    Upright::Traceroute::IpMetadataLookup.clear_cache
  end

  test "reached_destination? returns true when last hop responds" do
    result = Upright::Traceroute::Result.new("example.com")
    result.instance_variable_set(:@hops, [
      Upright::Traceroute::Hop.new(ip: "192.168.1.1"),
      Upright::Traceroute::Hop.new(ip: "8.8.8.8")
    ])

    assert result.reached_destination?
  end

  test "reached_destination? returns false when last hop is ???" do
    result = Upright::Traceroute::Result.new("example.com")
    result.instance_variable_set(:@hops, [
      Upright::Traceroute::Hop.new(ip: "192.168.1.1"),
      Upright::Traceroute::Hop.new(ip: nil)
    ])

    assert_not result.reached_destination?
  end

  test "reached_destination? returns false for empty hops" do
    result = Upright::Traceroute::Result.new("example.com")
    result.instance_variable_set(:@hops, [])

    assert_not result.reached_destination?
  end
end
