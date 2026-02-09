# frozen_string_literal: true

require "nokogiri"

module AgentFerrum
  module Content
    class VisibilityFilter
      FILTER_SCRIPT = <<~JS
        (() => {
          const clone = document.body.cloneNode(true);
          ['script','style','noscript','svg','path','meta','link',
           'template','iframe'].forEach(tag => {
            clone.querySelectorAll(tag).forEach(el => el.remove());
          });
          clone.querySelectorAll('[aria-hidden="true"]').forEach(el => el.remove());
          clone.querySelectorAll('[hidden]').forEach(el => el.remove());
          return clone.innerHTML;
        })()
      JS

      def initialize(browser)
        @browser = browser
      end

      def filtered_html
        raw_html = @browser.ferrum.evaluate(FILTER_SCRIPT)
        post_process(raw_html)
      end

      private

      def post_process(html)
        doc = Nokogiri::HTML::DocumentFragment.parse(html)
        doc.xpath("//comment()").remove
        doc.traverse do |node|
          next unless node.element?

          %w[style class data-testid data-cy onclick onload onerror].each { |attr| node.delete(attr) }
        end
        doc.to_html
      end
    end
  end
end
