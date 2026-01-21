require "test_helper"

class Upright::UptimeProbeTest < ActiveSupport::TestCase
  setup do
    @result = {
      metric: { name: "example.com", type: "http" },
      values: [
        [ 1.day.ago.to_i, "1.0" ],
        [ 2.days.ago.to_i, "0.95" ],
        [ 3.days.ago.to_i, "1.0" ]
      ]
    }
    @probe = Upright::UptimeProbe.new(@result)
  end

  test "name returns metric name" do
    assert_equal "example.com", @probe.name
  end

  test "type returns metric type" do
    assert_equal "http", @probe.type
  end

  test "overall_uptime calculates average percentage" do
    assert_in_delta 98.33, @probe.overall_uptime, 0.01
  end

  test "overall_uptime returns 0 when no values" do
    probe = Upright::UptimeProbe.new(metric: { name: "test", type: "http" }, values: [])
    assert_equal 0, probe.overall_uptime
  end

  test "uptime_for_date returns uptime value for specific date" do
    assert_equal 1.0, @probe.uptime_for_date(1.day.ago)
    assert_equal 0.95, @probe.uptime_for_date(2.days.ago)
  end

  test "uptime_for_date returns nil for missing date" do
    assert_nil @probe.uptime_for_date(10.days.ago)
  end
end
