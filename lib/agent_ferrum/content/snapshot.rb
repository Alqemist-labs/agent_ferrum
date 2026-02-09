# frozen_string_literal: true

module AgentFerrum
  module Content
    class Snapshot
      attr_reader :accessibility, :markdown_content, :url, :title, :refs

      def initialize(browser)
        @url = browser.current_url
        @title = browser.title

        filtered_html = VisibilityFilter.new(browser).filtered_html
        @accessibility = AccessibilityTree.new(browser)
        @refs = @accessibility.refs
        @markdown_content = MarkdownConverter.new(filtered_html).convert
      end

      def markdown
        @markdown_content
      end

      def accessibility_tree
        @accessibility.to_s
      end

      def to_s
        <<~SNAPSHOT
          # #{@title}
          URL: #{@url}

          ## Interactive Elements
          #{@accessibility}

          ## Page Content
          #{@markdown_content}
        SNAPSHOT
      end

      def estimated_tokens
        to_s.length / 4
      end
    end
  end
end
