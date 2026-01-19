require "test_helper"
require "webmock/minitest"

class ProbeCheckJobTest < ActiveSupport::TestCase
  setup do
    set_test_site
  end

  test "performs HTTP probe by class and name" do
    stub_request(:get, "https://example.com/").to_return(status: 200)

    assert_difference -> { Upright::ProbeResult.count } do
      Upright::ProbeCheckJob.perform_now("Upright::Probes::HTTPProbe", "Example")
    end
  end

  test "applies stagger delay before enqueue" do
    with_env("SITE_SUBDOMAIN" => "nyc") do
      job = Upright::ProbeCheckJob.new("Upright::Probes::HTTPProbe", "Example")
      job.enqueue

      assert_in_delta 3.seconds.from_now, job.scheduled_at, 5.seconds
    end
  end

  test "discards stale jobs older than 5 minutes" do
    stub_request(:get, "https://example.com/").to_return(status: 200)

    job = Upright::ProbeCheckJob.new("Upright::Probes::HTTPProbe", "Example")
    job.scheduled_at = 10.minutes.ago

    assert_no_difference -> { Upright::ProbeResult.count } do
      job.perform_now
    end
  end

  test "runs jobs scheduled within 5 minutes" do
    stub_request(:get, "https://example.com/").to_return(status: 200)

    job = Upright::ProbeCheckJob.new("Upright::Probes::HTTPProbe", "Example")
    job.scheduled_at = 2.minutes.ago

    assert_difference -> { Upright::ProbeResult.count } do
      job.perform_now
    end
  end
end
