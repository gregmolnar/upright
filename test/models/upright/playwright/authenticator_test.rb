require "test_helper"

class Upright::Playwright::AuthenticatorTest < ActiveSupport::TestCase
  include MockPlaywrightHelper

  class TestAuthenticator < Upright::Playwright::Authenticator::Base
    attr_accessor :session_should_be_valid, :test_service_name

    def initialize(browser, test_service_name)
      @test_service_name = test_service_name
      super(browser)
      @session_should_be_valid = true
    end

    private
      def service_name = test_service_name
      def authenticate = nil
      def context_has_valid_session?(context) = @session_should_be_valid
  end

  setup do
    @browser = MockBrowser.new
    @service_name = :"test_auth_#{SecureRandom.hex(4)}"
    @storage_state = Upright::Playwright::StorageState.new(@service_name)
  end

  teardown do
    @storage_state.clear
  end

  test "performs fresh authentication when no cached state" do
    authenticator = TestAuthenticator.new(@browser, @service_name)

    context = authenticator.authenticated_context

    assert_kind_of MockContext, context
    assert @storage_state.exists?
  end

  test "uses cached state when session is valid" do
    cached_state = { "cookies" => [ { "name" => "session", "value" => "cached" } ] }
    @storage_state.save(cached_state)
    authenticator = TestAuthenticator.new(@browser, @service_name)
    authenticator.session_should_be_valid = true

    context = authenticator.authenticated_context

    assert_equal cached_state, context.state
  end

  test "re-authenticates when cached session is invalid" do
    cached_state = { "cookies" => [ { "name" => "session", "value" => "expired" } ] }
    @storage_state.save(cached_state)
    authenticator = TestAuthenticator.new(@browser, @service_name)
    authenticator.session_should_be_valid = false

    context = authenticator.authenticated_context

    assert_not_equal cached_state, context.state
  end
end
