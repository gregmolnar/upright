require "test_helper"

class Upright::Playwright::StorageStateTest < ActiveSupport::TestCase
  setup do
    @storage_state = Upright::Playwright::StorageState.new(:"test_service_#{SecureRandom.hex(4)}")
  end

  teardown do
    @storage_state.clear
  end

  test "exists? returns false when no state saved" do
    assert_not @storage_state.exists?
  end

  test "save and load round-trips state" do
    state = { "cookies" => [ { "name" => "session", "value" => "abc123" } ] }

    @storage_state.save(state)

    assert @storage_state.exists?
    assert_equal state, @storage_state.load
  end
end
