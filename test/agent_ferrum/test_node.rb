# frozen_string_literal: true

require "test_helper"
require "ferrum"

class TestNode < Minitest::Test
  def setup
    @mock_ferrum_node = Minitest::Mock.new
  end

  def test_click_delegates_to_ferrum_node
    @mock_ferrum_node.expect(:evaluate, nil, [String])
    @mock_ferrum_node.expect(:click, nil)
    node = AgentFerrum::Node.new(@mock_ferrum_node)
    node.click
    @mock_ferrum_node.verify
  end

  def test_fill_calls_focus_and_type
    @mock_ferrum_node.expect(:focus, nil)
    @mock_ferrum_node.expect(:type, nil, ["hello"])
    node = AgentFerrum::Node.new(@mock_ferrum_node)
    node.fill("hello")
    @mock_ferrum_node.verify
  end

  def test_text_delegates
    @mock_ferrum_node.expect(:text, "Click me")
    node = AgentFerrum::Node.new(@mock_ferrum_node)
    assert_equal "Click me", node.text
    @mock_ferrum_node.verify
  end

  def test_value_delegates
    @mock_ferrum_node.expect(:value, "test@example.com")
    node = AgentFerrum::Node.new(@mock_ferrum_node)
    assert_equal "test@example.com", node.value
    @mock_ferrum_node.verify
  end

  def test_bracket_delegates
    @mock_ferrum_node.expect(:[], "submit", ["type"])
    node = AgentFerrum::Node.new(@mock_ferrum_node)
    assert_equal "submit", node["type"]
    @mock_ferrum_node.verify
  end

  def test_retry_on_node_moving_error
    call_count = 0
    fake_node = Object.new
    fake_node.define_singleton_method(:evaluate) { |_| nil }
    fake_node.define_singleton_method(:click) do
      call_count += 1
      raise Ferrum::NodeMovingError.new(nil, [0, 0], [1, 1]) if call_count < 3
    end
    node = AgentFerrum::Node.new(fake_node)
    node.click
    assert_equal 3, call_count
  end

  def test_raises_after_max_retries
    fake_node = Object.new
    fake_node.define_singleton_method(:evaluate) { |_| nil }
    fake_node.define_singleton_method(:click) do
      raise Ferrum::NodeMovingError.new(nil, [0, 0], [1, 1])
    end
    node = AgentFerrum::Node.new(fake_node)
    assert_raises(Ferrum::NodeMovingError) { node.click }
  end
end
