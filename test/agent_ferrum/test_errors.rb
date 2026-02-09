# frozen_string_literal: true

require "test_helper"

class TestErrors < Minitest::Test
  def test_base_error_inherits_standard_error
    assert AgentFerrum::Error < StandardError
  end

  def test_ref_not_found_error_inherits_base
    assert AgentFerrum::RefNotFoundError < AgentFerrum::Error
  end

  def test_ref_not_found_error_message
    error = AgentFerrum::RefNotFoundError.new("@e5")
    assert_includes error.message, "@e5"
    assert_includes error.message, "snapshot"
  end

  def test_element_not_found_error_inherits_base
    assert AgentFerrum::ElementNotFoundError < AgentFerrum::Error
  end

  def test_element_not_found_error_message
    error = AgentFerrum::ElementNotFoundError.new("#missing-btn")
    assert_includes error.message, "#missing-btn"
    assert_includes error.message, "selector"
  end

  def test_navigation_error_inherits_base
    assert AgentFerrum::NavigationError < AgentFerrum::Error
  end

  def test_stealth_error_inherits_base
    assert AgentFerrum::StealthError < AgentFerrum::Error
  end

  def test_waiter_timeout_error_inherits_base
    assert AgentFerrum::Waiter::TimeoutError < AgentFerrum::Error
  end
end
