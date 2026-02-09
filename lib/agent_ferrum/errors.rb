# frozen_string_literal: true

module AgentFerrum
  class Error < StandardError; end

  class RefNotFoundError < Error
    def initialize(ref)
      super("Element ref '#{ref}' not found. Call browser.snapshot to refresh refs.")
    end
  end

  class ElementNotFoundError < Error
    def initialize(selector)
      super("No element matches '#{selector}'. Check the selector or call snapshot to see available elements.")
    end
  end

  class NavigationError < Error; end
  class StealthError < Error; end
end
