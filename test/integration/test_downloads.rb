# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class TestDownloadsIntegration < Minitest::Test
  include BrowserTestHelper

  def setup
    setup_browser
  end

  def teardown
    teardown_browser
  end

  def test_download_path_setup
    Dir.mktmpdir do |dir|
      @browser.download_path = dir
      # Verify the path was set without error
      assert Dir.exist?(dir)
    end
  end
end
