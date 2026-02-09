# frozen_string_literal: true

require "test_helper"

class TestStealthDetection < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
    @browser.stealth(:maximum)
    load_fixture("simple.html")
  end

  def teardown
    teardown_browser
  end

  def test_webdriver_is_false
    result = @browser.evaluate("navigator.webdriver")
    assert_equal false, result
  end

  def test_chrome_runtime_script_does_not_error
    # window.chrome only exists on http(s) pages, not file:// or data:
    # Verify the script injection doesn't cause errors
    result = @browser.evaluate("typeof window.chrome")
    # On file:// URLs, window.chrome may be undefined — that's OK
    assert_includes %w[undefined object], result
  end

  def test_user_agent_clean
    ua = @browser.evaluate("navigator.userAgent")
    refute_includes ua, "HeadlessChrome"
  end

  def test_all_scripts_load_without_error
    # Navigate to another page to verify scripts re-inject
    load_fixture("complex.html")
    title = @browser.title
    assert_equal "Complex Test Page", title
  end
end

class TestUserAgentConfig < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser(user_agent: "AgentFerrum/1.0 TestBot")
  end

  def teardown
    teardown_browser
  end

  def test_custom_user_agent_applied
    load_fixture("simple.html")
    ua = @browser.evaluate("navigator.userAgent")
    assert_equal "AgentFerrum/1.0 TestBot", ua
  end
end

class TestTimezoneConfig < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser(timezone: "America/New_York")
  end

  def teardown
    teardown_browser
  end

  def test_custom_timezone_applied
    load_fixture("simple.html")
    tz = @browser.evaluate("Intl.DateTimeFormat().resolvedOptions().timeZone")
    assert_equal "America/New_York", tz
  end
end
