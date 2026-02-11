require "test_helper"

class Upright::Probes::Status::SiteStatusTest < ActiveSupport::TestCase
  test "up? returns true when latest value is 1" do
    status = build_status(values: [
      [ 5.minutes.ago.to_i, "1" ],
      [ 2.minutes.ago.to_i, "1" ]
    ])

    assert status.up?
    assert_not status.down?
  end

  test "down? returns true when latest value is 0" do
    status = build_status(values: [
      [ 5.minutes.ago.to_i, "1" ],
      [ 2.minutes.ago.to_i, "0" ]
    ])

    assert status.down?
    assert_not status.up?
  end

  test "down_since finds when continuous downtime started" do
    t1 = 10.minutes.ago.to_i
    t2 = 8.minutes.ago.to_i
    t3 = 6.minutes.ago.to_i
    t4 = 4.minutes.ago.to_i
    t5 = 2.minutes.ago.to_i

    status = build_status(values: [
      [ t1, "1" ],
      [ t2, "1" ],
      [ t3, "0" ],
      [ t4, "0" ],
      [ t5, "0" ]
    ])

    assert_equal Time.at(t3), status.down_since
  end

  test "down_since returns earliest timestamp when all values are 0" do
    t1 = 10.minutes.ago.to_i
    t2 = 5.minutes.ago.to_i
    t3 = 2.minutes.ago.to_i

    status = build_status(values: [
      [ t1, "0" ],
      [ t2, "0" ],
      [ t3, "0" ]
    ])

    assert_equal Time.at(t1), status.down_since
  end

  test "down_since returns nil when up" do
    status = build_status(values: [
      [ 2.minutes.ago.to_i, "1" ]
    ])

    assert_nil status.down_since
  end

  test "stale? returns true when latest data point is older than 5 minutes" do
    status = build_status(values: [
      [ 10.minutes.ago.to_i, "1" ]
    ])

    assert status.stale?
  end

  test "stale? returns false when latest data point is recent" do
    status = build_status(values: [
      [ 2.minutes.ago.to_i, "1" ]
    ])

    assert_not status.stale?
  end

  test "stale? returns true when values are empty" do
    status = build_status(values: [])

    assert status.stale?
  end

  test "exposes site_code and site_city" do
    status = build_status(site_code: "iad", site_city: "Ashburn")

    assert_equal "iad", status.site_code
    assert_equal "Ashburn", status.site_city
  end

  private
    def build_status(site_code: "iad", site_city: "Ashburn", values: [])
      Upright::Probes::Status::SiteStatus.new(
        site_code: site_code,
        site_city: site_city,
        values: values
      )
    end
end
