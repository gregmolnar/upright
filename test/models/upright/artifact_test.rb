require "test_helper"

class Upright::ArtifactTest < ActiveSupport::TestCase
  setup do
    set_test_site(code: "ams", city: "Amsterdam")
  end

  test "filename is the name passed in" do
    artifact = Upright::Artifact.new(name: "curl.log", content: "test")

    assert_equal "curl.log", artifact.filename
  end

  test "extension extracts from filename" do
    assert_equal "log", Upright::Artifact.new(name: "curl.log", content: "").extension
    assert_equal "webm", Upright::Artifact.new(name: "video.webm", content: "").extension
    assert_equal "json", Upright::Artifact.new(name: "response.json", content: "").extension
  end

  test "basename extracts from filename" do
    assert_equal "curl", Upright::Artifact.new(name: "curl.log", content: "").basename
    assert_equal "my_check", Upright::Artifact.new(name: "my_check.webm", content: "").basename
  end

  test "timestamped_filename includes timestamp, site code, and parameterized name" do
    travel_to Time.utc(2024, 6, 15, 10, 30, 45) do
      artifact = Upright::Artifact.new(name: "My Check Name.webm", content: "test")

      assert_equal "20240615_103045_ams_my_check_name.webm", artifact.timestamped_filename
    end
  end

  test "content_type uses Marcel for detection" do
    assert_equal "video/webm", Upright::Artifact.new(name: "test.webm", content: "").content_type
    assert_equal "application/json", Upright::Artifact.new(name: "test.json", content: "").content_type
    assert_equal "text/html", Upright::Artifact.new(name: "test.html", content: "").content_type
  end

  test "icon returns string for known extensions" do
    assert_equal "video", Upright::Artifact.new(name: "test.webm", content: "").icon
    assert_equal "log", Upright::Artifact.new(name: "test.log", content: "").icon
    assert_equal "download", Upright::Artifact.new(name: "test.json", content: "").icon
  end

  test "icon returns default for unknown extensions" do
    assert_equal "attachment", Upright::Artifact.new(name: "test.xyz", content: "").icon
  end

  test "attach_to attaches string content" do
    probe_result = Upright::ProbeResult.create!(
      probe_name: "test", probe_type: "http", probe_target: "example.com", status: :ok, duration: 0.1
    )

    Upright::Artifact.new(name: "curl.log", content: "test content").attach_to(probe_result)

    assert probe_result.artifacts.attached?
    assert_equal "curl.log", probe_result.artifacts.first.filename.to_s
    assert_equal "text/x-log", probe_result.artifacts.first.content_type
  end

  test "attach_to attaches StringIO content" do
    probe_result = Upright::ProbeResult.create!(
      probe_name: "test", probe_type: "http", probe_target: "example.com", status: :ok, duration: 0.1
    )

    Upright::Artifact.new(name: "response.json", content: StringIO.new('{"ok":true}')).attach_to(probe_result)

    assert probe_result.artifacts.attached?
    assert_equal "response.json", probe_result.artifacts.first.filename.to_s
  end

  test "attach_to with timestamped option uses timestamped filename" do
    travel_to Time.utc(2024, 6, 15, 10, 30, 45) do
      probe_result = Upright::ProbeResult.create!(
        probe_name: "test", probe_type: "playwright", probe_target: "example.com", status: :ok, duration: 0.1
      )

      Upright::Artifact.new(name: "my_check.log", content: "logs").attach_to(probe_result, timestamped: true)

      assert_equal "20240615_103045_ams_my_check.log", probe_result.artifacts.first.filename.to_s
    end
  end
end
