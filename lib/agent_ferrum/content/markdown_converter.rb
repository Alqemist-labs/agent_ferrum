# frozen_string_literal: true

require "reverse_markdown"

module AgentFerrum
  module Content
    class MarkdownConverter
      def initialize(html)
        @html = html
      end

      def convert
        md = ReverseMarkdown.convert(@html,
          unknown_tags:    :bypass,
          github_flavored: true)
        compact(md)
      end

      private

      def compact(markdown)
        markdown
          .gsub(/\n{3,}/, "\n\n")
          .gsub(/^[ \t]+$/, "")
          .gsub(/\[([^\]]*)\]\(\s*\)/, '\1')
          .gsub(/!\[\]\([^)]*\)/, "")
          .gsub(/\s+\n/, "\n")
          .strip
      end
    end
  end
end
