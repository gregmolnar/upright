require "test_helper"

class Upright::Traceroute::HopTest < ActiveSupport::TestCase
  test "responded? returns true when ip is present" do
    hop = Upright::Traceroute::Hop.new(ip: "8.8.8.8")
    assert hop.responded?
  end

  test "responded? returns false when ip is nil" do
    hop = Upright::Traceroute::Hop.new(ip: nil)
    assert_not hop.responded?
  end

  test "high_packet_loss? returns true when loss > 50%" do
    hop = Upright::Traceroute::Hop.new(loss_percent: 51)
    assert hop.high_packet_loss?
  end

  test "high_packet_loss? returns false when loss <= 50%" do
    hop = Upright::Traceroute::Hop.new(loss_percent: 50)
    assert_not hop.high_packet_loss?
  end

  test "any_packet_loss? returns true when loss > 0" do
    hop = Upright::Traceroute::Hop.new(loss_percent: 1)
    assert hop.any_packet_loss?
  end

  test "any_packet_loss? returns false when loss is 0" do
    hop = Upright::Traceroute::Hop.new(loss_percent: 0)
    assert_not hop.any_packet_loss?
  end

  test "display_name returns isp when available" do
    hop = Upright::Traceroute::Hop.new(ip: "8.8.8.8", isp: "Google LLC")
    assert_equal "Google LLC", hop.display_name
  end

  test "display_name returns ip when isp is not available" do
    hop = Upright::Traceroute::Hop.new(ip: "8.8.8.8")
    assert_equal "8.8.8.8", hop.display_name
  end

  test "display_name returns ??? when not responded" do
    hop = Upright::Traceroute::Hop.new(ip: nil)
    assert_equal "???", hop.display_name
  end
end
