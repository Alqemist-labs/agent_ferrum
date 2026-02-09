# frozen_string_literal: true

require "test_helper"

class TestMarkdownConverter < Minitest::Test
  def convert(html)
    AgentFerrum::Content::MarkdownConverter.new(html).convert
  end

  def test_heading_conversion
    assert_includes convert("<h1>Title</h1>"), "# Title"
  end

  def test_h2_conversion
    assert_includes convert("<h2>Subtitle</h2>"), "## Subtitle"
  end

  def test_paragraph
    md = convert("<p>Hello world</p>")
    assert_includes md, "Hello world"
  end

  def test_unordered_list
    html = "<ul><li>One</li><li>Two</li></ul>"
    md = convert(html)
    assert_includes md, "One"
    assert_includes md, "Two"
  end

  def test_ordered_list
    html = "<ol><li>First</li><li>Second</li></ol>"
    md = convert(html)
    assert_includes md, "First"
    assert_includes md, "Second"
  end

  def test_link_with_href
    html = '<a href="/about">About</a>'
    md = convert(html)
    assert_includes md, "[About](/about)"
  end

  def test_link_without_href_becomes_text
    html = '<a href="">About</a>'
    md = convert(html)
    assert_includes md, "About"
    refute_includes md, "[About]()"
  end

  def test_image_without_alt_removed
    html = '<p>Text</p><img src="photo.jpg"><p>More</p>'
    md = convert(html)
    refute_includes md, "photo.jpg"
  end

  def test_table_conversion
    html = "<table><tr><th>Name</th><th>Age</th></tr><tr><td>Alice</td><td>30</td></tr></table>"
    md = convert(html)
    assert_includes md, "Name"
    assert_includes md, "Alice"
  end

  def test_unknown_tags_dropped
    html = "<custom-element>Content</custom-element>"
    md = convert(html)
    refute_includes md, "custom-element"
  end

  def test_whitespace_compacted
    html = "<p>A</p>\n\n\n\n\n<p>B</p>"
    md = convert(html)
    refute_includes md, "\n\n\n"
  end

  def test_complex_html
    html = <<~HTML
      <div>
        <h1>Welcome</h1>
        <p>This is a <strong>test</strong> page.</p>
        <ul><li>Item 1</li><li>Item 2</li></ul>
        <a href="/home">Home</a>
      </div>
    HTML
    md = convert(html)
    assert_includes md, "# Welcome"
    assert_includes md, "**test**"
    assert_includes md, "[Home](/home)"
  end
end
