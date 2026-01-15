require "test_helper"

class Upright::NodeTest < ActiveSupport::TestCase
  setup do
    Upright::Node.reset!
  end

  test "extracts subdomain" do
    node = Upright::Node.new(
      hostname: "ams.37upright.com",
      tags: [ "amsterdam" ]
    )

    assert_equal "ams", node.subdomain
  end

  test "find by subdomain" do
    node = Upright::Node.find_by_subdomain("ams")

    assert_equal "Amsterdam", node.site.city
    assert_equal "NL", node.site.country
    assert_equal "u17982", node.site.geohash
    assert_equal "http://ams.upright.localhost:3040/", node.url
  end

  test "all loads nodes from deploy config" do
    nodes = Upright::Node.all

    assert nodes.size > 0, "Expected at least one node to be loaded"
    assert nodes.all? { |n| n.is_a?(Upright::Node) }
  end

  test "find_by_subdomain returns nil for unknown subdomain" do
    node = Upright::Node.find_by_subdomain("unknown")

    assert_nil node
  end
end
