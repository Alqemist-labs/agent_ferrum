# frozen_string_literal: true

module AgentFerrum
  class Configuration
    attr_accessor :headless, :timeout, :process_timeout, :poll_interval,
      :viewport, :stealth, :download_path,
      :browser_path, :chrome_args, :user_agent,
      :locale, :timezone

    def initialize
      @headless = true
      @timeout = 30
      @process_timeout = nil
      @poll_interval = 0.1
      @viewport = [1920, 1080]
      @stealth = :off
      @download_path = nil
      @browser_path = nil
      @chrome_args = []
      @user_agent = nil
      @locale = nil
      @timezone = nil
    end

    def initialize_dup(original)
      super
      @viewport = original.viewport.dup
      @chrome_args = original.chrome_args.dup
    end

    def ferrum_options
      opts = {
        headless:        @headless,
        timeout:         @timeout,
        window_size:     @viewport,
        browser_options: {}
      }
      opts[:process_timeout] = @process_timeout if @process_timeout
      opts[:browser_path] = @browser_path if @browser_path
      opts[:browser_options]["lang"] = @locale if @locale
      @chrome_args.each { |arg| opts[:browser_options][arg] = nil }
      opts
    end
  end
end
