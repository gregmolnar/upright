require "test_helper"

class Upright::Traceroute::ResultTest < ActiveSupport::TestCase
  setup do
    @result = Upright::Traceroute::Result.new("example.com")
  end

  test "reached_destination? returns true when last hop responds" do
    stub_mtr_with_fixture(@result, "mtr_reached_destination")

    assert @result.reached_destination?
  end

  test "reached_destination? returns false when last hop is ???" do
    stub_mtr_with_fixture(@result, "mtr_unreachable_destination")

    assert_not @result.reached_destination?
  end

  test "reached_destination? returns false for empty hops" do
    stub_mtr_with_fixture(@result, "mtr_empty_hops")

    assert_not @result.reached_destination?
  end
end
