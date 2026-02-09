# frozen_string_literal: true

require "minitest/autorun"
require "ferrum"
require "agent_ferrum"

# Shared browser singleton — one Chrome process for all tests
module SharedBrowser
  def self.instance
    @instance ||= begin
      AgentFerrum.reset_configuration!
      AgentFerrum.configure do |c|
        c.headless = true
        if ENV["CI"]
          c.process_timeout = 30
          c.chrome_args = %w[no-sandbox disable-gpu disable-dev-shm-usage]
        end
      end
      AgentFerrum::Browser.new
    end
  end

  def self.shutdown
    @instance&.quit
    @instance = nil
  end
end

Minitest.after_run { SharedBrowser.shutdown }

module BrowserTestHelper
  def setup_browser(**opts)
    AgentFerrum.reset_configuration!
    AgentFerrum.configure do |c|
      c.headless = true
      if ENV["CI"]
        c.process_timeout = 30
        c.chrome_args = %w[no-sandbox disable-gpu disable-dev-shm-usage]
      end
    end

    if opts.empty?
      @browser = SharedBrowser.instance
      @shared_browser = true
    else
      @browser = AgentFerrum::Browser.new(**opts)
      @shared_browser = false
    end
  end

  def teardown_browser
    return if @shared_browser

    @browser&.quit
  end

  def load_fixture(name)
    path = File.expand_path("fixtures/pages/#{name}", __dir__)
    @browser.navigate("file://#{path}")
  end

  def fixture_path(name)
    File.expand_path("fixtures/pages/#{name}", __dir__)
  end
end
