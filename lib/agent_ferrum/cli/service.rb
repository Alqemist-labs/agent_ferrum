# frozen_string_literal: true

module AgentFerrum
  class CLI
    class Service
      def initialize(browser)
        @browser = browser
      end

      def navigate(url)
        url = "https://#{url}" unless url.match?(%r{\Ahttps?://})
        @browser.navigate(url)
        "Navigated to #{@browser.current_url}"
      end

      def snapshot
        @browser.snapshot.to_s
      end

      def tree
        @browser.accessibility_tree.to_s
      end

      def markdown
        @browser.page_markdown
      end

      def click(target)
        url_before = @browser.current_url
        @browser.click(target)
        @browser.wait_for_navigation(timeout: 3) rescue nil
        url_after = @browser.current_url
        if url_after != url_before
          "Clicked #{target} → #{url_after}"
        else
          "Clicked #{target}"
        end
      end

      def fill(target, value)
        @browser.fill(target, value)
        "Filled #{target}"
      end

      def select_option(target, value)
        @browser.select(target, value)
        "Selected #{value} in #{target}"
      end

      def hover(target)
        @browser.hover(target)
        "Hovering #{target}"
      end

      def type_text(text)
        @browser.type_text(text)
        "Typed #{text}"
      end

      def current_url
        @browser.current_url
      end

      def title
        @browser.title
      end

      def eval_js(expression)
        @browser.evaluate(expression).inspect
      end

      def screenshot(path = nil)
        path ||= "screenshot_#{Time.now.strftime('%Y%m%d_%H%M%S')}.png"
        @browser.screenshot(path: path)
        "Screenshot saved to #{path}"
      end

      def back
        @browser.back
        "Back to #{@browser.current_url}"
      end

      def forward
        @browser.forward
        "Forward to #{@browser.current_url}"
      end

      def refresh
        @browser.refresh
        "Refreshed"
      end

      def stealth(profile)
        @browser.stealth(profile.to_sym)
        "Stealth set to #{profile}"
      end

      def wait(selector, timeout = nil)
        opts = selector.start_with?("/") ? { xpath: selector } : { css: selector }
        opts[:timeout] = timeout.to_i if timeout
        @browser.wait_for(**opts)
        "Element #{selector} found"
      end

      def stop
        @browser.quit
        "Stopped"
      end
    end
  end
end
