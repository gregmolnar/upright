require "test_helper"

class Upright::Traceroute::MtrParserTest < ActiveSupport::TestCase
  test "parses JSON output from mtr" do
    hops = parse_fixture("mtr_full_output")

    assert_equal 2, hops.length

    first_hop = hops[0]
    assert_equal 1, first_hop[:hop_number]
    assert_equal "192.168.1.1", first_hop[:ip]
    assert_equal 0.0, first_hop[:loss_percent]
    assert_equal 1.5, first_hop[:last_ms]
    assert_equal 1.2, first_hop[:avg_ms]
    assert_equal 0.9, first_hop[:best_ms]
    assert_equal 2.0, first_hop[:worst_ms]
    assert_equal 0.3, first_hop[:stddev_ms]

    second_hop = hops[1]
    assert_equal 2, second_hop[:hop_number]
    assert_equal "dns.google", second_hop[:hostname]
    assert second_hop[:ip].present?, "IP should be resolved from hostname"
    assert_equal 10.2, second_hop[:avg_ms]
  end

  test "handles missing hubs" do
    assert_equal [], parse_fixture("mtr_missing_hubs")
  end

  test "raises on invalid JSON" do
    assert_raises(JSON::ParserError) do
      Upright::Traceroute::MtrParser.new("not valid json").parse
    end
  end

  test "handles empty JSON" do
    assert_equal [], parse_fixture("mtr_empty_hops")
  end

  test "handles non-responding hop" do
    hops = parse_fixture("mtr_non_responding_hop")

    assert_equal 1, hops.length
    assert_nil hops[0][:ip]
    assert_equal 100.0, hops[0][:loss_percent]
  end

  private
    def parse_fixture(name)
      Upright::Traceroute::MtrParser.new(file_fixture("#{name}.json").read).parse
    end
end
