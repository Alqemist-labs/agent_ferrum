# frozen_string_literal: true

require "test_helper"

class TestStealthProfiles < Minitest::Test
  def test_minimal_contains_webdriver_only
    scripts = AgentFerrum::Stealth::Profiles.scripts_for(:minimal)
    assert_equal %w[webdriver], scripts
  end

  def test_moderate_contains_4_scripts
    scripts = AgentFerrum::Stealth::Profiles.scripts_for(:moderate)
    assert_equal 4, scripts.length
    assert_includes scripts, "webdriver"
    assert_includes scripts, "navigator_vendor"
    assert_includes scripts, "chrome_runtime"
    assert_includes scripts, "user_agent"
  end

  def test_maximum_contains_7_scripts
    scripts = AgentFerrum::Stealth::Profiles.scripts_for(:maximum)
    assert_equal 7, scripts.length
    assert_includes scripts, "navigator_plugins"
    assert_includes scripts, "webgl_vendor"
    assert_includes scripts, "iframe_content_window"
  end

  def test_unknown_profile_raises_error
    assert_raises(AgentFerrum::StealthError) do
      AgentFerrum::Stealth::Profiles.scripts_for(:nonexistent)
    end
  end
end
