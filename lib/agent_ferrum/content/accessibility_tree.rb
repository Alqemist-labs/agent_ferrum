# frozen_string_literal: true

module AgentFerrum
  module Content
    class AccessibilityTree
      INTERACTIVE_ROLES = %w[
        button link textbox checkbox radio combobox
        menuitem tab slider spinbutton searchbox switch
        option listbox menu menubar
      ].freeze

      attr_reader :refs, :nodes

      def initialize(browser)
        @browser = browser
        @refs = {}
        @nodes = []
        extract!
      end

      def to_s
        @nodes.map { |n| format_node(n) }.join("\n")
      end

      private

      def extract!
        result = @browser.ferrum.page.command("Accessibility.getFullAXTree")
        ax_nodes = result["nodes"]

        ref_counter = 0
        ax_nodes.each do |ax_node|
          role = ax_node.dig("role", "value")
          next unless INTERACTIVE_ROLES.include?(role)
          next if ignored?(ax_node)

          ref_counter += 1
          ref = "@e#{ref_counter}"

          node_info = {
            ref:             ref,
            role:            role,
            name:            ax_node.dig("name", "value") || "",
            value:           ax_node.dig("value", "value"),
            description:     ax_node.dig("description", "value"),
            backend_node_id: ax_node["backendDOMNodeId"],
            properties:      extract_properties(ax_node)
          }

          @refs[ref] = node_info
          @nodes << node_info
        end
      end

      def ignored?(ax_node)
        ignored = ax_node["ignored"]
        case ignored
        when Hash then ignored["value"] == true
        when true then true
        else false
        end
      end

      def extract_properties(ax_node)
        props = {}
        (ax_node["properties"] || []).each do |prop|
          name = prop["name"]
          value = prop.dig("value", "value")
          props[name] = value if %w[disabled required checked selected readonly].include?(name)
        end
        props
      end

      def format_node(node)
        parts = ["#{node[:ref]}: [#{node[:role]}] \"#{node[:name]}\""]
        parts << "value=\"#{node[:value]}\"" if node[:value]
        parts << node[:properties].map { |k, v| "#{k}=#{v}" }.join(" ") if node[:properties]&.any?
        parts.join(" ")
      end
    end
  end
end
