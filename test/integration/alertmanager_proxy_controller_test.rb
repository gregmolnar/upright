require "test_helper"
require "webmock/minitest"

class AlertmanagerProxyControllerTest < ActionDispatch::IntegrationTest
  setup do
    on_subdomain :app
    ENV["ALERTMANAGER_URL"] = "http://upright-alertmanager:9093"
  end

  test "proxies requests when authenticated" do
    stub_request(:get, "http://upright-alertmanager:9093/")
      .to_return(status: 200, body: "Alertmanager UI")

    sign_in
    get "/alertmanager"

    assert_response :success
  end
end
