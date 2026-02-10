# frozen_string_literal: true

require "ferrum"
require_relative "browser/target_resolution"

module AgentFerrum
  class Browser
    include TargetResolution

    attr_reader :ferrum, :config

    def initialize(**opts)
      @config = AgentFerrum.configuration.dup
      opts.each { |k, v| @config.public_send(:"#{k}=", v) if @config.respond_to?(:"#{k}=") }

      @ref_map = {}
      @stealth_manager = Stealth::Manager.new
      @ferrum = Ferrum::Browser.new(**@config.ferrum_options)
      @waiter = Waiter.new(self, default_timeout: @config.timeout, default_interval: @config.poll_interval)
      @downloads = Downloads.new(self)

      apply_stealth if @config.stealth != :off
      apply_user_agent if @config.user_agent
      apply_timezone if @config.timezone
      @downloads.download_path = @config.download_path if @config.download_path
    end

    # --- Navigation ---

    def navigate(url)
      @ferrum.goto(url)
    end

    def back
      @ferrum.back
    end

    def forward
      @ferrum.forward
    end

    def refresh
      @ferrum.refresh
    end

    # --- Content extraction ---

    def snapshot
      snap = Content::Snapshot.new(self)
      @ref_map = snap.refs
      snap
    end

    def page_markdown
      filtered_html = Content::VisibilityFilter.new(self).filtered_html
      Content::MarkdownConverter.new(filtered_html).convert
    end

    def accessibility_tree
      tree = Content::AccessibilityTree.new(self)
      @ref_map = tree.refs
      tree
    end

    # --- Actions ---

    def click(target)
      node = resolve_target(target)
      Node.new(node).click
    end

    def fill(target, value)
      node = resolve_target(target)
      Node.new(node).fill(value)
    end

    def select(target, value)
      node = resolve_target(target)
      Node.new(node).select(value)
    end

    def hover(target)
      node = resolve_target(target)
      Node.new(node).hover
    end

    def type_text(text)
      @ferrum.page.keyboard.type(text)
    end

    # --- Wait ---

    def wait_for(css: nil, xpath: nil, text: nil, timeout: nil, interval: nil, &)
      @waiter.call(css:, xpath:, text:, timeout:, interval:, &)
    end

    def wait_for_navigation(timeout: nil)
      timeout ||= @config.timeout
      @ferrum.network.wait_for_idle(timeout: timeout)
    end

    # --- Downloads ---

    def download_path=(path)
      @downloads.download_path = path
    end

    def wait_for_download(timeout: 30, filename: nil)
      @downloads.wait(timeout:, filename:)
    end

    # --- Stealth ---

    def stealth(profile)
      @config.stealth = profile
      apply_stealth
    end

    # --- Utils ---

    def current_url
      @ferrum.current_url
    end

    def title
      @ferrum.page.title
    end

    def evaluate(expression)
      @ferrum.evaluate(expression)
    end

    def screenshot(path: nil, selector: nil, full: false)
      opts = {}
      opts[:path] = path if path
      opts[:selector] = selector if selector
      opts[:full] = full
      @ferrum.screenshot(**opts)
    end

    def quit
      @ferrum.quit
    end

    private

    def apply_stealth
      @stealth_manager.apply(@ferrum.page, @config.stealth)
    end

    def apply_user_agent
      @ferrum.page.command("Network.setUserAgentOverride", userAgent: @config.user_agent)
    end

    def apply_timezone
      @ferrum.page.command("Emulation.setTimezoneOverride", timezoneId: @config.timezone)
    end
  end
end
