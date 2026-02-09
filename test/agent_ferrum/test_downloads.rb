# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class TestDownloads < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
  end

  def teardown
    teardown_browser
  end

  def test_download_path_creates_directory
    Dir.mktmpdir do |dir|
      path = File.join(dir, "downloads")
      @browser.download_path = path
      assert Dir.exist?(path)
    end
  end

  def test_wait_without_path_raises
    downloads = AgentFerrum::Downloads.new(@browser)
    assert_raises(AgentFerrum::Error) do
      downloads.wait(timeout: 1)
    end
  end
end
