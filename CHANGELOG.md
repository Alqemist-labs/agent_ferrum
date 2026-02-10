# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2026-02-10

### Fixed

- **`wait_for_navigation`** -- use `@ferrum.network.wait_for_idle` instead of `@ferrum.page.wait_for_idle` which doesn't exist in Ferrum 0.17.1 (`NoMethodError`)

## [0.2.0] - 2026-02-09

### Added

- **Standalone CLI** -- `agent_ferrum start/snapshot/click/stop` where each command is a separate invocation, ideal for AI agents chaining shell commands
  - Background daemon holds the Chrome browser process, communicating over a Unix domain socket (`UNIXSocket` + JSON protocol)
  - Zero external dependencies -- only Ruby stdlib
  - Session management via `~/.agent_ferrum/` (PID file + socket)
  - Full command set: `start`, `stop`, `status`, `navigate`, `snapshot`, `tree`, `markdown`, `click`, `fill`, `select`, `hover`, `type`, `screenshot`, `eval`, `back`, `forward`, `refresh`, `stealth`, `wait`
  - Start options: `--headed`, `--stealth`, `--user-agent`, `--viewport`, `--timeout`, `--browser-path`

### Improved

- **Click reliability** -- elements are scrolled into view (`scrollIntoView({block: 'center'})`) before clicking, fixing issues with elements covered by sticky headers or overlapping content on complex pages
- **Hover implementation** -- `Node#hover` now works via CDP mouse events (`scrollIntoView` + `find_position` + `mouse.move`), replacing Ferrum's `NotImplementedError`

## [0.1.0] - 2026-02-09

### Added

- **Hybrid snapshots** combining accessibility tree (interactive elements with `@eN` refs) and markdown content into a single compact output
- **Ref-based actions** -- `click`, `fill`, `select`, `hover` via `@e1`, `@e2`... refs from the snapshot
- **Visibility filtering** -- JS-based filtering removes hidden elements (display:none, visibility:hidden, aria-hidden, etc.), Nokogiri post-processing strips scripts, styles, and noise attributes
- **Markdown conversion** -- HTML to clean markdown via ReverseMarkdown with whitespace compaction
- **Stealth mode** -- Three profiles (`:minimal`, `:moderate`, `:maximum`) ported from puppeteer-extra-plugin-stealth
  - `:minimal` -- removes `navigator.webdriver` flag
  - `:moderate` -- adds vendor/platform spoofing, Chrome runtime, user-agent cleanup
  - `:maximum` -- adds navigator plugins, WebGL vendor masking, iframe fixes
- **Download management** -- set download path via CDP, wait for completion with timeout and optional filename filter
- **Smart waiting** -- poll for CSS/XPath/text/block conditions with configurable timeout and interval
- **Auto-retry** -- node actions retry automatically on `Ferrum::NodeMovingError` and `Ferrum::CoordinatesNotFoundError` (up to 3 attempts)
- **AI-friendly errors** -- `RefNotFoundError` and `ElementNotFoundError` include actionable messages guiding the agent
- **Configuration DSL** -- `AgentFerrum.configure` block or per-instance keyword arguments
- **Custom user-agent** via CDP `Network.setUserAgentOverride`
- **Timezone override** via CDP `Emulation.setTimezoneOverride`
- **Locale support** via Chrome browser options

[0.2.1]: https://github.com/Alqemist-labs/agent_ferrum/releases/tag/v0.2.1
[0.2.0]: https://github.com/Alqemist-labs/agent_ferrum/releases/tag/v0.2.0
[0.1.0]: https://github.com/Alqemist-labs/agent_ferrum/releases/tag/v0.1.0
