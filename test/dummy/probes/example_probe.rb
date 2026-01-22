class Probes::Playwright::ExampleProbe < Upright::Probes::Playwright::Base
  def probe_name = "Example: page load"

  def check
    page.goto("https://example.com")
    page.wait_for_selector("h1")
  end
end
