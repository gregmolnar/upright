require "test_helper"

class Upright::Traceroute::MtrParserTest < ActiveSupport::TestCase
  test "parses JSON output from mtr" do
    json_output = {
      "report" => {
        "mtr" => {
          "src" => "test-host",
          "dst" => "8.8.8.8",
          "tos" => 0,
          "tests" => 10,
          "psize" => "64",
          "bitpattern" => "0x00"
        },
        "hubs" => [
          {
            "count" => 1,
            "host" => "192.168.1.1",
            "ASN" => "AS???",
            "Loss%" => 0.0,
            "Snt" => 10,
            "Last" => 1.5,
            "Avg" => 1.2,
            "Best" => 0.9,
            "Wrst" => 2.0,
            "StDev" => 0.3
          },
          {
            "count" => 2,
            "host" => "dns.google",
            "ASN" => "AS15169",
            "Loss%" => 0.0,
            "Snt" => 10,
            "Last" => 10.5,
            "Avg" => 10.2,
            "Best" => 9.9,
            "Wrst" => 12.0,
            "StDev" => 0.5
          }
        ]
      }
    }.to_json

    hops = Upright::Traceroute::MtrParser.new(json_output).parse

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
    json_output = {
      "report" => {
        "mtr" => {}
      }
    }.to_json

    hops = Upright::Traceroute::MtrParser.new(json_output).parse

    assert_equal [], hops
  end

  test "raises on invalid JSON" do
    assert_raises(JSON::ParserError) do
      Upright::Traceroute::MtrParser.new("not valid json").parse
    end
  end

  test "handles empty JSON" do
    hops = Upright::Traceroute::MtrParser.new("{}").parse

    assert_equal [], hops
  end

  test "handles non-responding hop" do
    json_output = {
      "report" => {
        "hubs" => [
          {
            "count" => 1,
            "host" => "???",
            "ASN" => "AS???",
            "Loss%" => 100.0,
            "Snt" => 10,
            "Last" => 0.0,
            "Avg" => 0.0,
            "Best" => 0.0,
            "Wrst" => 0.0,
            "StDev" => 0.0
          }
        ]
      }
    }.to_json

    hops = Upright::Traceroute::MtrParser.new(json_output).parse

    assert_equal 1, hops.length
    assert_nil hops[0][:ip]
    assert_equal 100.0, hops[0][:loss_percent]
  end
end
