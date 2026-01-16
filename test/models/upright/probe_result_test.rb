require "test_helper"

class Upright::ProbeResultTest < ActiveSupport::TestCase
  test "to_chart returns expected structure" do
    result = upright_probe_results(:http_probe_result)
    chart_data = result.to_chart

    assert_equal result.created_at.iso8601, chart_data[:created_at]
    assert_equal result.duration.to_f, chart_data[:duration]
    assert_equal result.status, chart_data[:status]
    assert_equal result.probe_name, chart_data[:probe_name]
  end

  test "to_chart handles nil duration" do
    result = upright_probe_results(:http_probe_result)
    result.duration = nil
    chart_data = result.to_chart

    assert_equal 0.0, chart_data[:duration]
  end

  test "error attribute attaches exception report on create" do
    exception = RuntimeError.new("Something went wrong")
    exception.set_backtrace([ "app/models/foo.rb:10", "app/controllers/bar.rb:5" ])

    result = Upright::ProbeResult.create!(
      probe_name: "test", probe_type: "http", probe_target: "https://example.com",
      status: :error, duration: 1.0, error: exception
    )

    expected = <<~REPORT.chomp
      RuntimeError: Something went wrong
        app/models/foo.rb:10
        app/controllers/bar.rb:5
    REPORT
    assert_equal expected, result.exception_report
  end
end
