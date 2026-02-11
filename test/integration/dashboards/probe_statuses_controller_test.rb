require "test_helper"

class Upright::Dashboards::ProbeStatusesControllerTest < ActionDispatch::IntegrationTest
  test "shows probe status dashboard" do
    on_subdomain "app"
    sign_in
    stub_prometheus_query_range([])

    get upright.dashboards_probe_status_path

    assert_response :success
  end

  test "filters by probe type" do
    on_subdomain "app"
    sign_in
    stub_prometheus_query_range([
      { "metric" => { "name" => "example.com", "type" => "http", "probe_target" => "https://example.com", "site" => "iad" },
        "values" => [ [ 2.minutes.ago.to_i, "1" ] ] }
    ])

    get upright.dashboards_probe_status_path(probe_type: "http")

    assert_response :success
  end

  private
    def stub_prometheus_query_range(result)
      response = { status: "success", data: { resultType: "matrix", result: result } }

      stub_request(:get, /localhost:9090.*query_range/)
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })
    end
end
