require "test_helper"

class Upright::ArtifactTest < ActiveSupport::TestCase
  setup do
    set_test_site(code: "ams", city: "Amsterdam")
  end

  test "filename is the name passed in" do
    artifact = build_artifact(name: "curl.log")

    assert_equal "curl.log", artifact.filename
  end

  test "extension extracts from filename" do
    assert_equal "log", build_artifact(name: "curl.log").extension
  end

  test "basename extracts from filename" do
    assert_equal "curl", build_artifact(name: "curl.log").basename
    assert_equal "my_check", build_artifact(name: "my_check.webm").basename
  end

  test "timestamped_filename includes timestamp, site code, and parameterized name" do
    travel_to Time.utc(2024, 6, 15, 10, 30, 45) do
      artifact = build_artifact(name: "My Check Name.webm")

      assert_equal "20240615_103045_ams_my_check_name.webm", artifact.timestamped_filename
    end
  end

  test "content_type uses Marcel for detection" do
    assert_equal "video/webm",       build_artifact(name: "test.webm").content_type
    assert_equal "application/json", build_artifact(name: "test.json").content_type
    assert_equal "text/html",        build_artifact(name: "test.html").content_type
  end

  test "icon returns string for known extensions" do
    assert_equal "video",    build_artifact(name: "test.webm").icon
    assert_equal "log",      build_artifact(name: "test.log").icon
    assert_equal "download", build_artifact(name: "test.json").icon
  end

  test "icon returns default for unknown extensions" do
    assert_equal "attachment", build_artifact(name: "test.xyz").icon
  end

  test "attach_to attaches string content" do
    probe_result = upright_probe_results(:http_probe_result_without_artifacts)

    build_artifact(name: "curl.log", content: "test content").attach_to(probe_result)

    assert probe_result.artifacts.attached?
    assert_equal "curl.log",   probe_result.artifacts.first.filename.to_s
    assert_equal "text/x-log", probe_result.artifacts.first.content_type
  end

  test "attach_to attaches StringIO content" do
    probe_result = upright_probe_results(:http_probe_result_without_artifacts)

    build_artifact(name: "response.json", content: StringIO.new('{"ok":true}')).attach_to(probe_result)

    assert probe_result.artifacts.attached?
    assert_equal "response.json", probe_result.artifacts.first.filename.to_s
  end

  test "attach_to with timestamped option uses timestamped filename" do
    travel_to Time.utc(2024, 6, 15, 10, 30, 45) do
      probe_result = upright_probe_results(:playwright_probe_result_without_artifacts)

      build_artifact(name: "my_check.log", content: "logs").attach_to(probe_result, timestamped: true)

      assert_equal "20240615_103045_ams_my_check.log", probe_result.artifacts.first.filename.to_s
    end
  end

  private
    def build_artifact(name:, content: "")
      Upright::Artifact.new(name: name, content: content)
    end
end
