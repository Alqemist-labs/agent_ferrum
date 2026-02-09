# frozen_string_literal: true

require "test_helper"

class TestConfiguration < Minitest::Test
  def setup
    AgentFerrum.reset_configuration!
  end

  def test_default_headless
    assert_equal true, AgentFerrum.configuration.headless
  end

  def test_default_timeout
    assert_equal 30, AgentFerrum.configuration.timeout
  end

  def test_default_viewport
    assert_equal [1920, 1080], AgentFerrum.configuration.viewport
  end

  def test_default_stealth
    assert_equal :off, AgentFerrum.configuration.stealth
  end

  def test_default_poll_interval
    assert_equal 0.1, AgentFerrum.configuration.poll_interval
  end

  def test_configure_block
    AgentFerrum.configure do |c|
      c.headless = false
      c.timeout = 60
      c.stealth = :maximum
    end
    assert_equal false, AgentFerrum.configuration.headless
    assert_equal 60, AgentFerrum.configuration.timeout
    assert_equal :maximum, AgentFerrum.configuration.stealth
  end

  def test_ferrum_options_basic
    opts = AgentFerrum.configuration.ferrum_options
    assert_equal true, opts[:headless]
    assert_equal 30, opts[:timeout]
    assert_equal [1920, 1080], opts[:window_size]
  end

  def test_ferrum_options_with_browser_path
    AgentFerrum.configure { |c| c.browser_path = "/usr/bin/chromium" }
    opts = AgentFerrum.configuration.ferrum_options
    assert_equal "/usr/bin/chromium", opts[:browser_path]
  end

  def test_ferrum_options_without_browser_path
    opts = AgentFerrum.configuration.ferrum_options
    refute opts.key?(:browser_path)
  end

  def test_ferrum_options_with_locale
    AgentFerrum.configure { |c| c.locale = "fr-FR" }
    opts = AgentFerrum.configuration.ferrum_options
    assert_equal "fr-FR", opts[:browser_options]["lang"]
  end

  def test_dup_creates_independent_copy
    original = AgentFerrum.configuration
    copy = original.dup
    copy.timeout = 99
    copy.viewport[0] = 800
    assert_equal 30, original.timeout
    assert_equal 1920, original.viewport[0]
  end

  def test_default_download_path_nil
    assert_nil AgentFerrum.configuration.download_path
  end

  def test_default_chrome_args_empty
    assert_equal [], AgentFerrum.configuration.chrome_args
  end

  def test_default_user_agent_nil
    assert_nil AgentFerrum.configuration.user_agent
  end
end
