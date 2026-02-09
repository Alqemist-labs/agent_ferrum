# frozen_string_literal: true

require "socket"
require "json"

module AgentFerrum
  class CLI
    class Server
      def initialize(socket_path, options, ready_write_fd: nil)
        @socket_path = socket_path
        @options = options
        @ready_write_fd = ready_write_fd
        @running = false
      end

      def run
        browser = AgentFerrum::Browser.new(**@options)
        @service = Service.new(browser)
        @running = true

        File.delete(@socket_path) if File.exist?(@socket_path)
        @server = UNIXServer.new(@socket_path)
        signal_ready

        while @running
          client = @server.accept
          handle_connection(client)
        end
      rescue StandardError => e
        signal_error(e)
        raise
      ensure
        @server&.close
        File.delete(@socket_path) if @socket_path && File.exist?(@socket_path)
      end

      private

      def handle_connection(client)
        raw = client.gets("\n")
        return unless raw

        request = JSON.parse(raw)
        method = request["method"]
        args = request["args"] || []

        if method == "stop"
          client.puts(JSON.generate(result: "Stopped"))
          client.close
          @service.stop
          @running = false
          return
        end

        result = @service.public_send(method, *args)
        client.puts(JSON.generate(result: result))
      rescue NoMethodError
        client.puts(JSON.generate(error: "Unknown method: #{method}"))
      rescue StandardError => e
        client.puts(JSON.generate(error: e.message))
      ensure
        client&.close unless client&.closed?
      end

      def signal_ready
        return unless @ready_write_fd

        io = IO.for_fd(@ready_write_fd)
        io.write("ready")
        io.close
      end

      def signal_error(error)
        return unless @ready_write_fd

        io = IO.for_fd(@ready_write_fd)
        io.write("error:#{error.message}")
        io.close
      rescue StandardError
        # fd may already be closed
      end
    end
  end
end
