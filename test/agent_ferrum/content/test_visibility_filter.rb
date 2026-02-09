# frozen_string_literal: true

require "test_helper"

class TestVisibilityFilter < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
  end

  def teardown
    teardown_browser
  end

  def test_removes_script_tags
    load_fixture("hidden_elements.html")
    html = AgentFerrum::Content::VisibilityFilter.new(@browser).filtered_html
    refute_includes html, "<script"
  end

  def test_removes_style_tags
    load_fixture("hidden_elements.html")
    html = AgentFerrum::Content::VisibilityFilter.new(@browser).filtered_html
    refute_includes html, "<style"
  end

  def test_removes_aria_hidden
    load_fixture("hidden_elements.html")
    html = AgentFerrum::Content::VisibilityFilter.new(@browser).filtered_html
    refute_includes html, "Hidden by aria"
  end

  def test_removes_hidden_attribute
    load_fixture("hidden_elements.html")
    html = AgentFerrum::Content::VisibilityFilter.new(@browser).filtered_html
    refute_includes html, "Hidden by attribute"
  end

  def test_preserves_visible_content
    load_fixture("hidden_elements.html")
    html = AgentFerrum::Content::VisibilityFilter.new(@browser).filtered_html
    assert_includes html, "Visible paragraph"
    assert_includes html, "Visible Button"
  end

  def test_removes_style_attributes
    load_fixture("hidden_elements.html")
    html = AgentFerrum::Content::VisibilityFilter.new(@browser).filtered_html
    refute_includes html, "style="
  end

  def test_removes_class_attributes
    load_fixture("complex.html")
    html = AgentFerrum::Content::VisibilityFilter.new(@browser).filtered_html
    refute_includes html, "class="
  end

  def test_preserves_href_attributes
    load_fixture("simple.html")
    html = AgentFerrum::Content::VisibilityFilter.new(@browser).filtered_html
    assert_includes html, "href="
  end

  def test_removes_html_comments
    load_fixture("hidden_elements.html")
    html = AgentFerrum::Content::VisibilityFilter.new(@browser).filtered_html
    refute_includes html, "<!--"
  end
end
