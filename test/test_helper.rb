# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"
require "mocha/minitest"
require "webmock/minitest"

# Load Yabeda testing adapter (metrics configured by engine)
require "yabeda/testing"

# Load test helpers
Dir.glob(File.expand_path("lib/helpers/**/*.rb", __dir__)).each do |helper|
  require helper
end

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    include IpApiHelper
    include SiteHelper
    include PlaywrightHelper
    include YabedaTestHelper

    def with_env(env_vars)
      original_values = env_vars.keys.to_h { |k| [ k, ENV[k] ] }
      env_vars.each { |k, v| ENV[k] = v }
      yield
    ensure
      original_values.each { |k, v| ENV[k] = v }
    end

    def stub_ip_api_batch(response_body = "[]")
      stub_request(:post, "http://ip-api.com/batch").to_return(status: 200, body: response_body)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include SubdomainHelper, AuthenticationHelper

    def upright
      Upright::Engine.routes.url_helpers
    end
  end
end
