require "socket"

module PlaywrightHelper
  def skip_unless_playwright_running
    return if ENV["CI"] # never skip in CI

    config = Rails.application.config_for(:playwright)
    uri = URI.parse(config.fetch(:server_url))

    TCPSocket.new(uri.host, uri.port).close
  rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
    skip "Playwright server not running on #{uri.host}:#{uri.port}"
  end
end
