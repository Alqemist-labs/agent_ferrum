# frozen_string_literal: true

require "test_helper"

class TestBrowserNavigation < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
  end

  def teardown
    teardown_browser
  end

  def test_navigate_and_current_url
    load_fixture("simple.html")
    assert_includes @browser.current_url, "simple.html"
  end

  def test_title
    load_fixture("simple.html")
    assert_equal "Simple Test Page", @browser.title
  end

  def test_navigate_sets_page
    load_fixture("form.html")
    assert_includes @browser.current_url, "form.html"
  end

  def test_back_and_forward
    load_fixture("simple.html")
    @browser.current_url
    load_fixture("form.html")
    @browser.back
    assert_includes @browser.current_url, "simple.html"
    @browser.forward
    assert_includes @browser.current_url, "form.html"
  end

  def test_refresh
    load_fixture("simple.html")
    @browser.refresh
    assert_includes @browser.current_url, "simple.html"
  end

  def test_evaluate_js
    load_fixture("simple.html")
    result = @browser.evaluate("1 + 2")
    assert_equal 3, result
  end

  def test_evaluate_returns_page_data
    load_fixture("simple.html")
    title = @browser.evaluate("document.title")
    assert_equal "Simple Test Page", title
  end

  def test_screenshot_returns_data
    load_fixture("simple.html")
    data = @browser.screenshot
    refute_nil data
  end

  def test_quit_closes_browser
    @browser.quit
    assert_raises { @browser.evaluate("1") }
    @browser = nil
  end
end

class TestBrowserActions < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
  end

  def teardown
    teardown_browser
  end

  def test_click_css_selector
    load_fixture("interactive.html")
    @browser.click("button")
  end

  def test_fill_css_selector
    load_fixture("form.html")
    @browser.fill("input[name='email']", "test@example.com")
    value = @browser.evaluate("document.querySelector('input[name=\"email\"]').value")
    assert_equal "test@example.com", value
  end

  def test_click_invalid_selector_raises
    load_fixture("simple.html")
    assert_raises(AgentFerrum::ElementNotFoundError) do
      @browser.click("#nonexistent-element-xyz")
    end
  end

  def test_click_invalid_ref_raises
    load_fixture("simple.html")
    assert_raises(AgentFerrum::RefNotFoundError) do
      @browser.click("@e999")
    end
  end

  def test_snapshot_returns_snapshot
    load_fixture("interactive.html")
    snap = @browser.snapshot
    assert_instance_of AgentFerrum::Content::Snapshot, snap
    refute_empty snap.to_s
  end

  def test_page_markdown_returns_string
    load_fixture("simple.html")
    md = @browser.page_markdown
    assert_kind_of String, md
    refute_empty md
  end

  def test_wait_for_css
    load_fixture("simple.html")
    result = @browser.wait_for(css: "h1", timeout: 5)
    refute_nil result
  end

  def test_wait_for_text
    load_fixture("simple.html")
    result = @browser.wait_for(text: "Simple", timeout: 5)
    refute_nil result
  end

  def test_wait_for_timeout
    load_fixture("simple.html")
    assert_raises(AgentFerrum::Waiter::TimeoutError) do
      @browser.wait_for(css: "#never-exists", timeout: 0.3)
    end
  end

  def test_xpath_selector
    load_fixture("simple.html")
    @browser.click("//a")
  end

  def test_hash_css_selector
    load_fixture("interactive.html")
    @browser.click(css: "button")
  end

  def test_hash_xpath_selector
    load_fixture("interactive.html")
    @browser.click(xpath: "//button")
  end
end
