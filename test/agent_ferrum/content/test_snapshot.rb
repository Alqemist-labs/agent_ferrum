# frozen_string_literal: true

require "test_helper"

class TestSnapshot < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
  end

  def teardown
    teardown_browser
  end

  def test_url_is_correct
    load_fixture("simple.html")
    snap = AgentFerrum::Content::Snapshot.new(@browser)
    assert_includes snap.url, "simple.html"
  end

  def test_title_is_correct
    load_fixture("simple.html")
    snap = AgentFerrum::Content::Snapshot.new(@browser)
    assert_equal "Simple Test Page", snap.title
  end

  def test_markdown_returns_string
    load_fixture("complex.html")
    snap = AgentFerrum::Content::Snapshot.new(@browser)
    refute_empty snap.markdown
  end

  def test_markdown_contains_headings
    load_fixture("complex.html")
    snap = AgentFerrum::Content::Snapshot.new(@browser)
    assert_includes snap.markdown, "Welcome"
  end

  def test_accessibility_tree_returns_string
    load_fixture("interactive.html")
    snap = AgentFerrum::Content::Snapshot.new(@browser)
    refute_empty snap.accessibility_tree
  end

  def test_refs_populated
    load_fixture("interactive.html")
    snap = AgentFerrum::Content::Snapshot.new(@browser)
    refute_empty snap.refs
  end

  def test_to_s_combines_all
    load_fixture("complex.html")
    snap = AgentFerrum::Content::Snapshot.new(@browser)
    output = snap.to_s
    assert_includes output, "Interactive Elements"
    assert_includes output, "Page Content"
    assert_includes output, snap.title
  end

  def test_estimated_tokens_reasonable
    load_fixture("complex.html")
    snap = AgentFerrum::Content::Snapshot.new(@browser)
    tokens = snap.estimated_tokens
    assert tokens.positive?
    assert tokens < 100_000
  end

  def test_snapshot_smaller_than_raw_html
    load_fixture("complex.html")
    raw_html = @browser.evaluate("document.documentElement.outerHTML")
    snap = AgentFerrum::Content::Snapshot.new(@browser)
    assert snap.to_s.length < raw_html.length, "Snapshot should be smaller than raw HTML"
  end
end
