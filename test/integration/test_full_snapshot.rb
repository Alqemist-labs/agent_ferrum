# frozen_string_literal: true

require "test_helper"

class TestFullSnapshot < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
  end

  def teardown
    teardown_browser
  end

  def test_snapshot_on_complex_page
    load_fixture("complex.html")
    snap = @browser.snapshot
    output = snap.to_s

    assert_includes output, "Welcome"
    assert_includes output, "Page Content"
    assert_includes output, "Interactive Elements"
  end

  def test_refs_contain_interactive_elements
    load_fixture("interactive.html")
    snap = @browser.snapshot
    roles = snap.refs.values.map { |n| n[:role] }
    assert_includes roles, "button"
    assert_includes roles, "link"
  end

  def test_click_via_ref
    load_fixture("interactive.html")
    snap = @browser.snapshot
    # Find a button ref
    button_ref = snap.refs.find { |_k, v| v[:role] == "button" }&.first
    refute_nil button_ref, "Should find a button ref"
    # Click should not raise
    @browser.click(button_ref)
  end

  def test_snapshot_reduction_ratio
    load_fixture("complex.html")
    raw_html = @browser.evaluate("document.documentElement.outerHTML")
    snap = @browser.snapshot
    ratio = snap.to_s.length.to_f / raw_html.length
    assert ratio < 0.8, "Snapshot should be significantly smaller than HTML (ratio: #{ratio})"
  end

  def test_hidden_elements_excluded
    load_fixture("hidden_elements.html")
    snap = @browser.snapshot
    md = snap.markdown
    refute_includes md, "Hidden by aria"
    refute_includes md, "Hidden by attribute"
    assert_includes md, "Visible paragraph"
  end
end
