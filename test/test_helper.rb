# frozen_string_literal: true

require "minitest/autorun"
require "ferrum"
require "agent_ferrum"

module BrowserTestHelper
  def setup_browser(**)
    AgentFerrum.reset_configuration!
    AgentFerrum.configure do |c|
      c.headless = true
      if ENV["CI"]
        c.process_timeout = 30
        c.chrome_args = %w[--no-sandbox --disable-gpu --disable-dev-shm-usage]
      end
    end
    @browser = AgentFerrum::Browser.new(**)
  end

  def teardown_browser
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
