# frozen_string_literal: true

module AgentFerrum
  class Waiter
    def initialize(browser, default_timeout:, default_interval:)
      @browser = browser
      @default_timeout = default_timeout
      @default_interval = default_interval
    end

    def call(css: nil, xpath: nil, text: nil, timeout: nil, interval: nil, &)
      timeout ||= @default_timeout
      interval ||= @default_interval
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

      loop do
        result = check_condition(css:, xpath:, text:, &)
        return result if result

        remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
        raise Waiter::TimeoutError, build_message(css:, xpath:, text:, timeout:) if remaining <= 0

        sleep [interval, remaining].min
      end
    end

    class TimeoutError < AgentFerrum::Error; end

    private

    def check_condition(css:, xpath:, text:, &block)
      if block
        block.call(@browser)
      elsif css
        @browser.ferrum.at_css(css)
      elsif xpath
        @browser.ferrum.at_xpath(xpath)
      elsif text
        @browser.ferrum.at_xpath("//*[contains(text(), '#{escape_xpath(text)}')]")
      end
    rescue Ferrum::NodeNotFoundError
      nil
    end

    def escape_xpath(str)
      str.gsub("'", "\\\\'")
    end

    def build_message(css:, xpath:, text:, timeout:)
      target = css || xpath || text || "block condition"
      "Timeout (#{timeout}s) waiting for: #{target}"
    end
  end
end
