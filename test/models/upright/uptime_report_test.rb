require "test_helper"

class Upright::UptimeReportTest < ActiveSupport::TestCase
  test "probes returns sorted UptimeProbe objects" do
    stub_prometheus_query_range([
      { "metric" => { "name" => "zebra.com", "type" => "http" }, "values" => [] },
      { "metric" => { "name" => "alpha.com", "type" => "http" }, "values" => [] },
      { "metric" => { "name" => "beta.com", "type" => "smtp" }, "values" => [] }
    ])

    report = Upright::UptimeReport.new(probe_type: "http")
    probes = report.probes

    assert_equal 3, probes.size
    assert_equal %w[ alpha.com zebra.com beta.com ], probes.map(&:name)
  end

  test "probes returns empty array when no results" do
    stub_prometheus_query_range([])

    report = Upright::UptimeReport.new(probe_type: "http")

    assert_equal [], report.probes
  end

  private
    def stub_prometheus_query_range(result)
      response = { status: "success", data: { resultType: "matrix", result: result } }

      stub_request(:get, /prometheus.*query_range/)
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })
    end
end
