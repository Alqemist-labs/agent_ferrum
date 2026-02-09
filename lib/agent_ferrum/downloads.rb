# frozen_string_literal: true

require "fileutils"

module AgentFerrum
  class Downloads
    def initialize(browser)
      @browser = browser
      @download_path = nil
    end

    def download_path=(path)
      @download_path = File.expand_path(path)
      FileUtils.mkdir_p(@download_path)
      @browser.ferrum.page.command("Browser.setDownloadBehavior",
        behavior:     "allow",
        downloadPath: @download_path)
    end

    attr_reader :download_path

    def wait(timeout: 30, filename: nil)
      raise AgentFerrum::Error, "Download path not set. Set download_path first." unless @download_path

      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

      loop do
        match = find_completed_download(filename)
        return match if match && File.mtime(match) > (Time.now - timeout)

        remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
        raise Waiter::TimeoutError, "Download timeout (#{timeout}s)" if remaining <= 0

        sleep 0.5
      end
    end

    private

    def find_completed_download(filename)
      files = Dir.glob(File.join(@download_path, "*"))
                 .reject { |f| f.end_with?(".crdownload", ".tmp") }
                 .select { |f| File.file?(f) }

      if filename
        files.find { |f| File.basename(f) == filename }
      else
        files.max_by { |f| File.mtime(f) }
      end
    end
  end
end
