# frozen_string_literal: true

require "test_helper"

class TestStealthManager < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
  end

  def teardown
    teardown_browser
  end

  def test_apply_minimal_injects_webdriver_fix
    manager = AgentFerrum::Stealth::Manager.new
    manager.apply(@browser.ferrum.page, :minimal)
    @browser.navigate("about:blank")
    result = @browser.evaluate("navigator.webdriver")
    assert_equal false, result
  end

  def test_scripts_load_without_syntax_error
    manager = AgentFerrum::Stealth::Manager.new
    # Should not raise any errors
    manager.apply(@browser.ferrum.page, :maximum)
    @browser.navigate("about:blank")
    # Page should still work
    assert_equal "about:blank", @browser.current_url
  end
end
