require "test_helper"

class Upright::Probes::UptimeTest < ActiveSupport::TestCase
  test ".for_type returns sorted Summary objects" do
    stub_prometheus_query_range([
      { "metric" => { "name" => "zebra.com", "type" => "http" }, "values" => [] },
      { "metric" => { "name" => "alpha.com", "type" => "http" }, "values" => [] },
      { "metric" => { "name" => "beta.com", "type" => "smtp" }, "values" => [] }
    ])

    summaries = Upright::Probes::Uptime.for_type(:http)

    assert_equal 3, summaries.size
    assert_equal %w[ alpha.com zebra.com beta.com ], summaries.map(&:name)
  end

  test ".for_type returns empty array when no results" do
    stub_prometheus_query_range([])

    assert_equal [], Upright::Probes::Uptime.for_type(:http)
  end

  test ".all returns all probe types" do
    stub_prometheus_query_range([
      { "metric" => { "name" => "example.com", "type" => "http" }, "values" => [] }
    ])

    summaries = Upright::Probes::Uptime.all

    assert_equal 1, summaries.size
  end

  private
    def stub_prometheus_query_range(result)
      response = { status: "success", data: { resultType: "matrix", result: result } }

      stub_request(:get, /localhost:9090.*query_range/)
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })
    end
end
