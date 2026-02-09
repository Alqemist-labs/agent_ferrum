# frozen_string_literal: true

module AgentFerrum
  module Stealth
    class Manager
      SCRIPTS_DIR = File.join(__dir__, "scripts")

      def apply(page, profile)
        scripts = Profiles.scripts_for(profile)
        scripts.each do |script_name|
          js = load_script(script_name)
          page.command("Page.addScriptToEvaluateOnNewDocument", source: js)
        end

        # Override user-agent at CDP level if included in the profile
        return unless scripts.include?("user_agent")

        current_ua = page.command("Runtime.evaluate", expression: "navigator.userAgent").dig("result", "value") || ""
        return unless current_ua.include?("HeadlessChrome")

        clean_ua = current_ua.gsub("HeadlessChrome", "Chrome")
        page.command("Network.setUserAgentOverride", userAgent: clean_ua)
      end

      private

      def load_script(name)
        utils = File.read(File.join(SCRIPTS_DIR, "utils.js"))
        script = File.read(File.join(SCRIPTS_DIR, "#{name}.js"))
        "#{utils}\n#{script}"
      end
    end
  end
end
