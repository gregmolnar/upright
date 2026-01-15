module MockPlaywrightHelper
  class MockBrowser
    def new_context(**options)
      MockContext.new(options[:storageState])
    end
  end

  class MockContext
    attr_reader :state

    def initialize(state = nil)
      @state = state
      @closed = false
    end

    def new_page = MockPage.new
    def storage_state = { "cookies" => [ { "name" => "session", "value" => "fresh" } ] }
    def close = @closed = true
    def closed? = @closed
  end

  class MockPage
    def goto(url, **options) = nil
    def url = "https://example.com/"
    def close = nil
    def on(event, callback) = nil
  end
end
