# frozen_string_literal: true

require "socket"
require "json"

module AgentFerrum
  class CLI
    class Client
      class ConnectionError < AgentFerrum::Error; end
      class RemoteError < AgentFerrum::Error; end

      def initialize(socket_path)
        @socket_path = socket_path
      end

      def call(method, *args)
        socket = UNIXSocket.new(@socket_path)
        request = { method: method, args: args }
        socket.puts(JSON.generate(request))

        raw = socket.gets("\n")
        raise ConnectionError, "No response from daemon" unless raw

        response = JSON.parse(raw)
        raise RemoteError, response["error"] if response["error"]

        response["result"]
      rescue Errno::ENOENT, Errno::ECONNREFUSED
        raise ConnectionError, "No browser running. Start one with: agent_ferrum start"
      ensure
        socket&.close
      end
    end
  end
end
