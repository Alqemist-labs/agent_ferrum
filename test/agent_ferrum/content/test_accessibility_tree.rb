# frozen_string_literal: true

require "test_helper"

class TestAccessibilityTree < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
  end

  def teardown
    teardown_browser
  end

  def test_extracts_buttons
    load_fixture("interactive.html")
    tree = AgentFerrum::Content::AccessibilityTree.new(@browser)
    roles = tree.nodes.map { |n| n[:role] }
    assert_includes roles, "button"
  end

  def test_extracts_links
    load_fixture("interactive.html")
    tree = AgentFerrum::Content::AccessibilityTree.new(@browser)
    roles = tree.nodes.map { |n| n[:role] }
    assert_includes roles, "link"
  end

  def test_extracts_textboxes
    load_fixture("form.html")
    tree = AgentFerrum::Content::AccessibilityTree.new(@browser)
    roles = tree.nodes.map { |n| n[:role] }
    assert_includes roles, "textbox"
  end

  def test_refs_assigned_sequentially
    load_fixture("interactive.html")
    tree = AgentFerrum::Content::AccessibilityTree.new(@browser)
    refs = tree.nodes.map { |n| n[:ref] }
    assert refs.first.start_with?("@e")
    # Check sequential numbering
    numbers = refs.map { |r| r.delete("@e").to_i }
    assert_equal numbers, (1..numbers.length).to_a
  end

  def test_refs_hash_maps_to_node_info
    load_fixture("interactive.html")
    tree = AgentFerrum::Content::AccessibilityTree.new(@browser)
    refute_empty tree.refs
    first_ref = tree.refs.keys.first
    info = tree.refs[first_ref]
    assert info.key?(:role)
    assert info.key?(:name)
    assert info.key?(:backend_node_id)
  end

  def test_to_s_produces_readable_output
    load_fixture("interactive.html")
    tree = AgentFerrum::Content::AccessibilityTree.new(@browser)
    output = tree.to_s
    assert_includes output, "@e1:"
    assert_includes output, "["
    assert_includes output, "]"
  end

  def test_backend_node_id_stored
    load_fixture("form.html")
    tree = AgentFerrum::Content::AccessibilityTree.new(@browser)
    tree.nodes.each do |node|
      refute_nil node[:backend_node_id], "Node #{node[:ref]} should have backend_node_id"
    end
  end
end
