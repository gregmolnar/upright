require "test_helper"

class ArtifactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in
    on_subdomain "ams"
  end

  test "shows text artifact content" do
    attachment = active_storage_attachments(:http_artifact)
    ActiveStorage::Attachment.any_instance.stubs(:download).returns("Sample log content")

    get upright.site_artifact_path(attachment)

    assert_response :success
    assert_select "pre", text: "Sample log content"
  end

  test "shows video artifact with video player" do
    attachment = active_storage_attachments(:playwright_video_artifact)

    get upright.site_artifact_path(attachment)

    assert_response :success
    assert_select "video[controls]"
    assert_select "source[type='video/webm']"
    assert_select "source[src*='rails/active_storage/blobs']"
  end

  test "redirects to authentication when not signed in" do
    sign_out
    attachment = active_storage_attachments(:http_artifact)

    get upright.site_artifact_path(attachment)

    assert_redirected_to upright.new_admin_session_url(subdomain: "app")
  end
end
