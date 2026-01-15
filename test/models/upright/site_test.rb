require "test_helper"

class Upright::SiteTest < ActiveSupport::TestCase
  test "provider returns a string inquirer" do
    site = Upright::Site.new(code: "ams", provider: "digitalocean")

    assert site.provider.digitalocean?
    assert_not site.provider.hetzner?
  end

  test "provider inquiry works for hetzner" do
    site = Upright::Site.new(code: "nbg", provider: "hetzner")

    assert site.provider.hetzner?
    assert_not site.provider.digitalocean?
  end

  test "provider inquiry handles nil" do
    site = Upright::Site.new(code: "test", provider: nil)

    assert_not site.provider.digitalocean?
    assert_not site.provider.hetzner?
  end
end
