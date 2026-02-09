# frozen_string_literal: true

require "optparse"
require "json"
require "socket"
require "fileutils"

require_relative "cli/service"
require_relative "cli/server"
require_relative "cli/client"

module AgentFerrum
  class CLI
    SESSION_DIR = File.expand_path("~/.agent_ferrum")
    SESSION_FILE = File.join(SESSION_DIR, "session.json")
    SOCKET_PATH = File.join(SESSION_DIR, "agent_ferrum.sock")

    def self.run(argv)
      new(argv).execute
    end

    def initialize(argv)
      @argv = argv.dup
      @command = @argv.shift
    end

    def execute
      case @command
      when "start"   then cmd_start
      when "stop"    then cmd_stop
      when "status"  then cmd_status
      when "version" then puts "agent_ferrum #{AgentFerrum::VERSION}"
      when "help", nil, "-h", "--help" then print_help
      else cmd_remote
      end
    end

    private

    # --- Commands ---

    def cmd_start
      cleanup_stale_session

      if session_alive?
        $stderr.puts "Browser already running (pid: #{read_session["pid"]}). Stop it first with: agent_ferrum stop"
        exit 1
      end

      options = parse_start_options

      ready_read, ready_write = IO.pipe

      pid = fork do
        ready_read.close
        $stdin.reopen("/dev/null")
        $stdout.reopen("/dev/null")
        $stderr.reopen("/dev/null")
        Process.setsid
        Server.new(SOCKET_PATH, options, ready_write_fd: ready_write.fileno).run
      end

      ready_write.close
      Process.detach(pid)
      write_session(pid: pid)
      wait_for_daemon(ready_read)

      url = @argv.shift
      if url
        client = connect
        puts client.call(:navigate, url)
      end

      puts "Browser started (pid: #{pid})"
    end

    def cmd_stop
      unless session_alive?
        $stderr.puts "No browser running."
        cleanup_session
        exit 1
      end

      begin
        client = connect
        client.call(:stop)
      rescue Client::ConnectionError
        # Daemon already gone, kill the process
        session = read_session
        Process.kill("TERM", session["pid"]) if session
      rescue StandardError
        # ignore
      end

      cleanup_session
      puts "Browser stopped."
    end

    def cmd_status
      if session_alive?
        session = read_session
        client = connect
        url = client.call(:current_url) rescue "unknown"
        puts "Browser running (pid: #{session["pid"]})"
        puts "URL: #{url}"
      else
        cleanup_session
        puts "No browser running."
      end
    end

    def cmd_remote
      client = connect

      result = case @command
               when "navigate", "go"      then client.call(:navigate, @argv[0])
               when "snapshot", "snap"    then client.call(:snapshot)
               when "tree"                then client.call(:tree)
               when "markdown", "md"      then client.call(:markdown)
               when "click"               then client.call(:click, @argv[0])
               when "fill"                then client.call(:fill, @argv[0], @argv[1..].join(" "))
               when "select"              then client.call(:select_option, @argv[0], @argv[1..].join(" "))
               when "hover"               then client.call(:hover, @argv[0])
               when "type"                then client.call(:type_text, @argv.join(" "))
               when "url"                 then client.call(:current_url)
               when "title"               then client.call(:title)
               when "eval"                then client.call(:eval_js, @argv.join(" "))
               when "screenshot"          then client.call(:screenshot, @argv[0])
               when "back"                then client.call(:back)
               when "forward"             then client.call(:forward)
               when "refresh"             then client.call(:refresh)
               when "stealth"             then client.call(:stealth, @argv[0])
               when "wait"                then client.call(:wait, @argv[0], @argv[1])
               else
                 $stderr.puts "Unknown command: #{@command}. Run 'agent_ferrum help' for usage."
                 exit 1
               end

      puts result
    rescue Client::ConnectionError => e
      $stderr.puts e.message
      exit 1
    rescue Client::RemoteError => e
      $stderr.puts "Error: #{e.message}"
      exit 1
    end

    # --- Session management ---

    def write_session(pid:)
      FileUtils.mkdir_p(SESSION_DIR)
      File.write(SESSION_FILE, JSON.generate(pid: pid, socket: SOCKET_PATH))
    end

    def read_session
      return nil unless File.exist?(SESSION_FILE)

      JSON.parse(File.read(SESSION_FILE))
    end

    def cleanup_session
      File.delete(SESSION_FILE) if File.exist?(SESSION_FILE)
      File.delete(SOCKET_PATH) if File.exist?(SOCKET_PATH)
    end

    def session_alive?
      session = read_session
      return false unless session

      Process.kill(0, session["pid"])
      true
    rescue Errno::ESRCH, Errno::EPERM
      false
    end

    def cleanup_stale_session
      return unless File.exist?(SESSION_FILE) && !session_alive?

      cleanup_session
    end

    def connect
      Client.new(SOCKET_PATH)
    end

    def wait_for_daemon(ready_read, timeout: 30)
      result = IO.select([ready_read], nil, nil, timeout)

      unless result
        $stderr.puts "Timeout waiting for browser daemon to start."
        exit 1
      end

      message = ready_read.read
      ready_read.close

      if message.start_with?("error:")
        $stderr.puts "Failed to start browser: #{message.sub('error:', '')}"
        exit 1
      end
    end

    # --- Option parsing ---

    def parse_start_options
      options = {}

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: agent_ferrum start [URL] [options]"

        opts.on("--headed", "Run in headed mode (visible browser)") do
          options[:headless] = false
        end

        opts.on("--stealth PROFILE", "Stealth profile: off, minimal, moderate, maximum") do |v|
          options[:stealth] = v.to_sym
        end

        opts.on("--user-agent UA", "Custom user agent string") do |v|
          options[:user_agent] = v
        end

        opts.on("--viewport WxH", "Viewport size (e.g. 1920x1080)") do |v|
          w, h = v.split("x").map(&:to_i)
          options[:viewport] = [w, h]
        end

        opts.on("--timeout N", Integer, "Timeout in seconds") do |v|
          options[:timeout] = v
        end

        opts.on("--browser-path PATH", "Path to Chrome binary") do |v|
          options[:browser_path] = v
        end
      end

      parser.parse!(@argv)
      options
    end

    # --- Help ---

    def print_help
      puts <<~HELP
        agent_ferrum — Browser automation CLI for AI agents

        Usage: agent_ferrum <command> [args] [options]

        Session:
          start [URL] [options]   Start the browser daemon
            --headed              Visible browser (default: headless)
            --stealth PROFILE     off / minimal / moderate / maximum
            --user-agent UA       Custom user agent
            --viewport WxH        Viewport size (default: 1920x1080)
            --timeout N           Timeout in seconds (default: 30)
            --browser-path PATH   Path to Chrome binary
          stop                    Stop the browser daemon
          status                  Show browser status

        Navigation:
          navigate URL            Navigate to URL (alias: go)
          back                    Go back
          forward                 Go forward
          refresh                 Reload page

        Content:
          snapshot                Full snapshot: accessibility tree + markdown (alias: snap)
          tree                    Accessibility tree only
          markdown                Page markdown only (alias: md)
          url                     Current URL
          title                   Page title

        Actions:
          click TARGET            Click element (ref @e1 or CSS selector)
          fill TARGET VALUE       Fill an input field
          select TARGET VALUE     Select a dropdown option
          hover TARGET            Hover over element
          type TEXT               Type text via keyboard

        Utilities:
          screenshot [PATH]       Take a screenshot
          eval JS                 Evaluate JavaScript
          stealth PROFILE         Change stealth profile
          wait SELECTOR [TIMEOUT] Wait for element (CSS or XPath)

        Other:
          help                    Show this help
          version                 Show version
      HELP
    end
  end
end
