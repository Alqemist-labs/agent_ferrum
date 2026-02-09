# frozen_string_literal: true

require "test_helper"

class TestWaiter < Minitest::Test
  def setup
    @mock_ferrum = Object.new
    @mock_ferrum.define_singleton_method(:at_css) { |_sel| nil }
    @mock_ferrum.define_singleton_method(:at_xpath) { |_sel| nil }
    mock_ferrum = @mock_ferrum
    @mock_browser = Object.new
    @mock_browser.define_singleton_method(:ferrum) { mock_ferrum }
    @waiter = AgentFerrum::Waiter.new(@mock_browser, default_timeout: 2, default_interval: 0.05)
  end

  def test_wait_for_block_returns_truthy
    result = @waiter.call { |_b| "found" }
    assert_equal "found", result
  end

  def test_wait_for_block_waits_then_returns
    call_count = 0
    result = @waiter.call do |_b|
      call_count += 1
      call_count >= 3 ? "done" : nil
    end
    assert_equal "done", result
    assert call_count >= 3
  end

  def test_timeout_raises_error
    assert_raises(AgentFerrum::Waiter::TimeoutError) do
      @waiter.call(timeout: 0.1) { |_b| nil }
    end
  end

  def test_timeout_error_message_includes_details
    error = assert_raises(AgentFerrum::Waiter::TimeoutError) do
      @waiter.call(css: ".missing", timeout: 0.1)
    end
    assert_includes error.message, ".missing"
    assert_includes error.message, "0.1"
  end

  def test_custom_timeout_overrides_default
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    assert_raises(AgentFerrum::Waiter::TimeoutError) do
      @waiter.call(timeout: 0.2) { |_b| nil }
    end
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    assert_in_delta 0.2, elapsed, 0.15
  end
end
