require "test_helper"

class SitesControllerTest < ActionDispatch::IntegrationTest
  test "redirects from no subdomain to app subdomain" do
    on_subdomain nil

    get upright.root_path

    assert_redirected_to upright.root_url(subdomain: "app")
  end

  test "shows sites index on app subdomain without redirect loop" do
    on_subdomain "app"
    sign_in

    get upright.root_path

    assert_response :success
    assert_equal "sites", @controller.controller_name
  end
end
