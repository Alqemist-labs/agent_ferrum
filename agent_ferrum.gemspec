# frozen_string_literal: true

require_relative "lib/agent_ferrum/version"

Gem::Specification.new do |spec|
  spec.name = "agent_ferrum"
  spec.version = AgentFerrum::VERSION
  spec.authors = ["Florian"]
  spec.email = ["florian@alqemist.com"]
  spec.summary = "Browser automation library optimized for AI agents"
  spec.description = "Wraps Ferrum (Chrome headless via CDP) with AI-optimized content extraction: " \
                     "accessibility tree with refs, compact markdown snapshots, and stealth mode."
  spec.homepage = "https://github.com/Alqemist-labs/agent_ferrum"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ferrum", "~> 0.17"
  spec.add_dependency "nokogiri", "~> 1.16"
  spec.add_dependency "reverse_markdown", "~> 3.0"
  spec.add_dependency "zeitwerk", "~> 2.7"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
end
