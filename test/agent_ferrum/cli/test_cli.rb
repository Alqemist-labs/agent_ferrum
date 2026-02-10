# frozen_string_literal: true

require_relative "../../test_helper"
require "agent_ferrum/cli"
require "json"
require "fileutils"
require "socket"

class TestCLI < Minitest::Test
  def test_version_output
    out, = capture_io { AgentFerrum::CLI.run(["version"]) }
    assert_match(/agent_ferrum #{Regexp.escape(AgentFerrum::VERSION)}/, out)
  end

  def test_help_output
    out, = capture_io { AgentFerrum::CLI.run(["help"]) }
    assert_includes out, "agent_ferrum"
    assert_includes out, "start"
    assert_includes out, "stop"
    assert_includes out, "snapshot"
    assert_includes out, "click"
  end

  def test_nil_command_shows_help
    out, = capture_io { AgentFerrum::CLI.run([]) }
    assert_includes out, "agent_ferrum"
    assert_includes out, "start"
  end

  def test_h_flag_shows_help
    out, = capture_io { AgentFerrum::CLI.run(["-h"]) }
    assert_includes out, "agent_ferrum"
  end

  def test_help_flag_shows_help
    out, = capture_io { AgentFerrum::CLI.run(["--help"]) }
    assert_includes out, "agent_ferrum"
  end

  def test_unknown_command_without_daemon_exits
    assert_raises(SystemExit) do
      capture_io { AgentFerrum::CLI.run(["unknowncmd"]) }
    end
  end
end

class TestCLIClient < Minitest::Test
  def test_connection_error_on_missing_socket
    client = AgentFerrum::CLI::Client.new("/tmp/nonexistent_#{Process.pid}.sock")
    assert_raises(AgentFerrum::CLI::Client::ConnectionError) do
      client.call(:snapshot)
    end
  end
end

class TestCLIService < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
    @service = AgentFerrum::CLI::Service.new(@browser)
  end

  def teardown
    teardown_browser
  end

  def test_navigate_adds_https
    result = @service.navigate("example.com")
    assert_match(/Navigated to https:\/\/example\.com/, result)
  end

  def test_navigate_preserves_http_scheme
    result = @service.navigate("http://example.com")
    assert_match(/Navigated to/, result)
    assert_includes result, "example.com"
  end

  def test_current_url
    @service.navigate("https://example.com")
    assert_equal "https://example.com/", @service.current_url
  end

  def test_title
    @service.navigate("https://example.com")
    assert_equal "Example Domain", @service.title
  end

  def test_snapshot_returns_string
    @service.navigate("https://example.com")
    result = @service.snapshot
    assert_kind_of String, result
    assert_includes result, "Example Domain"
  end

  def test_tree_returns_string
    @service.navigate("https://example.com")
    result = @service.tree
    assert_kind_of String, result
  end

  def test_markdown_returns_string
    @service.navigate("https://example.com")
    result = @service.markdown
    assert_kind_of String, result
    assert_includes result, "Example Domain"
  end

  def test_eval_js
    @service.navigate("https://example.com")
    result = @service.eval_js("1 + 1")
    assert_equal "2", result
  end

  def test_screenshot
    @service.navigate("https://example.com")
    path = File.join(Dir.tmpdir, "test_screenshot_#{Process.pid}.png")
    result = @service.screenshot(path)
    assert_includes result, "Screenshot saved to #{path}"
    assert File.exist?(path)
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_back
    @service.navigate("https://example.com")
    result = @service.back
    assert_match(/Back to/, result)
  end

  def test_refresh
    @service.navigate("https://example.com")
    result = @service.refresh
    assert_equal "Refreshed", result
  end

  def test_click_link_navigates
    @service.navigate("https://example.com")
    @service.snapshot  # load refs
    result = @service.click("@e1")
    assert_match(/Clicked @e1/, result)
    # "Learn more" link should navigate away from example.com
    assert_match(/→/, result)
    refute_equal "https://example.com/", @service.current_url
  end

  def test_click_without_navigation
    load_fixture("form.html")
    @service.snapshot
    # Click the reset button — no navigation expected
    result = @service.click("button[type='reset']")
    assert_match(/Clicked/, result)
    refute_includes result, "→"
  end

  def test_forward
    @service.navigate("https://example.com")
    @service.snapshot
    @service.click("@e1")  # navigate away
    @service.back
    result = @service.forward
    assert_match(/Forward to/, result)
  end

  def test_screenshot_default_path
    @service.navigate("https://example.com")
    result = @service.screenshot
    assert_match(/Screenshot saved to screenshot_\d{8}_\d{6}\.png/, result)
    path = result.sub("Screenshot saved to ", "")
    File.delete(path) if File.exist?(path)
  end

  def test_stealth
    result = @service.stealth("moderate")
    assert_equal "Stealth set to moderate", result
  end

  def test_fill
    load_fixture("form.html")
    result = @service.fill("input[name='email']", "test@example.com")
    assert_equal "Filled input[name='email']", result
  end

  def test_select_option
    load_fixture("form.html")
    result = @service.select_option("select[name='country']", "France")
    assert_equal "Selected France in select[name='country']", result
  end

  def test_hover
    @service.navigate("https://example.com")
    @service.snapshot
    result = @service.hover("@e1")
    assert_equal "Hovering @e1", result
  end

  def test_type_text
    load_fixture("form.html")
    @browser.click("input[name='email']")  # focus the input
    result = @service.type_text("hello")
    assert_equal "Typed hello", result
  end

  def test_wait_css
    load_fixture("form.html")
    result = @service.wait("input[name='email']")
    assert_equal "Element input[name='email'] found", result
  end

  def test_wait_xpath
    load_fixture("form.html")
    result = @service.wait("//button[@type='submit']")
    assert_equal "Element //button[@type='submit'] found", result
  end

  def test_stop
    # Use a dedicated browser so we don't kill the shared one
    dedicated = AgentFerrum::Browser.new(headless: true)
    service = AgentFerrum::CLI::Service.new(dedicated)
    result = service.stop
    assert_equal "Stopped", result
  end
end
