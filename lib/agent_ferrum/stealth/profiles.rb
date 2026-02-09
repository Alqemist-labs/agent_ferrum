# frozen_string_literal: true

module AgentFerrum
  module Stealth
    module Profiles
      PROFILES = {
        minimal:  %w[webdriver],
        moderate: %w[webdriver navigator_vendor chrome_runtime user_agent],
        maximum:  %w[webdriver navigator_vendor navigator_plugins chrome_runtime
                     webgl_vendor iframe_content_window user_agent]
      }.freeze

      def self.scripts_for(profile)
        PROFILES.fetch(profile) do
          raise StealthError, "Unknown stealth profile: #{profile}. Valid: #{PROFILES.keys.join(", ")}"
        end
      end
    end
  end
end
