require "test_helper"

class Upright::Probes::Uptime::SummaryTest < ActiveSupport::TestCase
  setup do
    @result = {
      metric: { name: "example.com", type: "http" },
      values: [
        [ 1.day.ago.to_i, "1.0" ],
        [ 2.days.ago.to_i, "0.95" ],
        [ 3.days.ago.to_i, "1.0" ]
      ]
    }
    @summary = Upright::Probes::Uptime::Summary.new(@result)
  end

  test "name returns metric name" do
    assert_equal "example.com", @summary.name
  end

  test "type returns metric type" do
    assert_equal "http", @summary.type
  end

  test "overall_uptime calculates average percentage" do
    assert_in_delta 98.33, @summary.overall_uptime, 0.01
  end

  test "overall_uptime returns 0 when no values" do
    summary = Upright::Probes::Uptime::Summary.new(metric: { name: "test", type: "http" }, values: [])
    assert_equal 0, summary.overall_uptime
  end

  test "uptime_for_date returns uptime value for specific date" do
    assert_equal 1.0, @summary.uptime_for_date(1.day.ago)
    assert_equal 0.95, @summary.uptime_for_date(2.days.ago)
  end

  test "uptime_for_date returns nil for missing date" do
    assert_nil @summary.uptime_for_date(10.days.ago)
  end

  test "summaries are sortable by type and name" do
    http_alpha = Upright::Probes::Uptime::Summary.new(metric: { name: "alpha.com", type: "http" }, values: [])
    http_beta = Upright::Probes::Uptime::Summary.new(metric: { name: "beta.com", type: "http" }, values: [])
    smtp_alpha = Upright::Probes::Uptime::Summary.new(metric: { name: "alpha.com", type: "smtp" }, values: [])

    assert_equal [ http_alpha, http_beta, smtp_alpha ], [ smtp_alpha, http_beta, http_alpha ].sort
  end
end
