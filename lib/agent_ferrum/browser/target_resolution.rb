module AgentFerrum
  class Browser
    module TargetResolution
      private

      def resolve_target(target)
        case target
        when /\A@e\d+\z/
          resolve_ref(target)
        when Hash
          resolve_hash_target(target)
        when %r{\A/}
          find_by_xpath(target)
        else
          find_by_css(target)
        end
      end

      def resolve_hash_target(target)
        if target[:css]
          find_by_css(target[:css])
        elsif target[:xpath]
          find_by_xpath(target[:xpath])
        else
          raise ArgumentError, "Hash target must have :css or :xpath key"
        end
      end

      def resolve_ref(ref)
        node_info = @ref_map[ref]
        raise RefNotFoundError, ref unless node_info

        backend_node_id = node_info[:backend_node_id]

        result = @ferrum.page.command("DOM.resolveNode", backendNodeId: backend_node_id)
        object_id = result.dig("object", "objectId")

        desc = @ferrum.page.command("DOM.describeNode", backendNodeId: backend_node_id)
        description = desc["node"]

        push_result = @ferrum.page.command("DOM.requestNode", objectId: object_id)
        node_id = push_result["nodeId"]

        frame = @ferrum.page.main_frame
        target_id = @ferrum.page.target_id
        Ferrum::Node.new(frame, target_id, node_id, description)
      end

      def find_by_css(selector)
        node = @ferrum.at_css(selector)
        raise ElementNotFoundError, selector unless node

        node
      end

      def find_by_xpath(xpath)
        node = @ferrum.at_xpath(xpath)
        raise ElementNotFoundError, xpath unless node

        node
      end
    end
  end
end
