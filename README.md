# AgentFerrum

[![Gem Version](https://badge.fury.io/rb/agent_ferrum.svg)](https://badge.fury.io/rb/agent_ferrum) [![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.4-ruby.svg)](https://www.ruby-lang.org) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Browser automation for AI agents, in Ruby.** Powered by [Ferrum](https://github.com/rubycdp/ferrum).

AgentFerrum wraps Chrome headless (via CDP) with an AI-optimized extraction layer. Instead of dumping raw HTML into your agent's context, it produces a compact snapshot: a markdown rendering of the visible page content + an accessibility tree of interactive elements with clickable refs. Typical reduction: **50-80% fewer tokens** compared to raw HTML (the heavier the page, the bigger the savings).

> Inspired by [agent-browser](https://github.com/vercel-labs/agent-browser) (Vercel) for the accessibility tree + refs concept, [Crucible](https://github.com/joshfng/crucible) for stealth profiles and download management, and [FerrumMCP](https://github.com/Eth3rnit3/FerrumMCP) for Ruby/Ferrum patterns.

## Why AgentFerrum?

Most browser automation tools return the full DOM or raw HTML. An LLM agent processing a typical web page receives **thousands of tokens** of noise (scripts, styles, hidden elements, data attributes). AgentFerrum solves this with a hybrid snapshot:

```
# Shopping Cart                          # What your agent sees
URL: https://shop.example.com/cart

## Interactive Elements                  # Clickable refs
@e1: [link] "Home" href="/"
@e2: [link] "Products" href="/products"
@e3: [textbox] "Search" value=""
@e4: [button] "Remove"
@e5: [button] "Checkout"

## Page Content                          # Clean markdown
# Your Cart

| Product | Qty | Price |
|---------|-----|-------|
| Widget  | 2   | $20   |

Total: **$20.00**
```

Your agent reads a compact snapshot instead of the full DOM. It clicks `@e5` to checkout. Done.

## Benchmark

Real-world token reduction measured on live pages (February 2026):

| Site | Raw HTML | Snapshot | Reduction |
|------|----------|----------|-----------|
| **Hacker News** | ~8,600 tokens | ~4,500 tokens | **47%** |
| **Wikipedia** (Ruby article) | ~140,000 tokens | ~31,000 tokens | **78%** |
| **GitHub** (repo page) | ~265,000 tokens | ~22,000 tokens | **92%** |

The heavier the page (scripts, styles, data attributes, hidden elements), the bigger the savings. Simple content-focused pages like HN see ~50% reduction. Rich web apps like GitHub or StackOverflow see 90%+.

## Features

- **Hybrid snapshots** -- Accessibility tree (interactive elements with refs) + markdown (visible content), combined into a single compact output
- **Ref-based actions** -- Click, fill, select, hover via `@e1`, `@e2`... refs from the snapshot. No CSS selectors needed
- **Visibility filtering** -- JS-based filtering removes hidden elements, then Nokogiri strips scripts, styles, and noise attributes
- **Markdown conversion** -- HTML to clean markdown via [ReverseMarkdown](https://github.com/xijo/reverse_markdown), with whitespace compaction
- **Stealth mode** -- Three profiles (`:minimal`, `:moderate`, `:maximum`) ported from puppeteer-extra-plugin-stealth
- **Download management** -- Set download path, wait for completion with timeout
- **Smart waiting** -- Poll for CSS/XPath/text/block conditions with configurable timeout and interval
- **Auto-retry** -- Node actions retry automatically on transient errors (element moving, coordinates not found)
- **AI-friendly errors** -- Error messages tell the agent what to do next ("Call browser.snapshot to refresh refs")

## Installation

Add to your Gemfile:

```ruby
gem "agent_ferrum"
```

Then:

```bash
bundle install
```

**Requirements:** Ruby 3.4+, Chrome/Chromium installed.

## Quick Start

### 1. Navigate and snapshot

```ruby
require "agent_ferrum"

browser = AgentFerrum::Browser.new
browser.navigate("https://example.com")

snap = browser.snapshot
puts snap.to_s
# => Compact snapshot with interactive elements + markdown content
```

### 2. Interact via refs

```ruby
snap = browser.snapshot

# Click a button by ref
browser.click("@e3")

# Fill a text field by ref
browser.fill("@e2", "search query")

# Or use CSS/XPath selectors
browser.click("button.submit")
browser.click("//a[@href='/about']")
browser.fill(css: "input[name='email']", "user@example.com")
```

### 3. Wait for content

```ruby
# Wait for an element
browser.wait_for(css: ".results", timeout: 10)

# Wait for text to appear
browser.wait_for(text: "Search complete")

# Wait for a custom condition
browser.wait_for { |b| b.evaluate("document.readyState") == "complete" }
```

### 4. Extract content

```ruby
# Full snapshot (accessibility tree + markdown)
snap = browser.snapshot
puts snap.to_s              # Combined output for AI
puts snap.markdown           # Just the markdown content
puts snap.accessibility_tree # Just the interactive elements
puts snap.estimated_tokens   # Approximate token count

# Quick markdown only
puts browser.page_markdown
```

### 5. Clean up

```ruby
browser.quit
```

## Configuration

```ruby
AgentFerrum.configure do |c|
  c.headless = true          # Run headless (default: true)
  c.timeout = 30             # Default timeout in seconds
  c.poll_interval = 0.1      # Polling interval for wait_for
  c.viewport = [1920, 1080]  # Browser viewport size
  c.stealth = :off           # Stealth profile: :off, :minimal, :moderate, :maximum
  c.download_path = nil      # Directory for downloads
  c.browser_path = nil       # Custom Chrome/Chromium path
  c.user_agent = nil         # Custom user agent
  c.locale = nil             # Browser locale (e.g., "fr-FR")
end
```

Or pass options directly:

```ruby
browser = AgentFerrum::Browser.new(headless: false, timeout: 60, stealth: :maximum)
```

## Stealth Mode

Three profiles of increasing evasion, ported from [puppeteer-extra-plugin-stealth](https://github.com/berstend/puppeteer-extra/tree/master/packages/puppeteer-extra-plugin-stealth):

| Profile     | Scripts | What it does                                                   |
| ----------- | ------- | -------------------------------------------------------------- |
| `:minimal`  | 1       | Removes `navigator.webdriver` flag                             |
| `:moderate` | 4       | + Vendor/platform spoofing, Chrome runtime, user-agent cleanup |
| `:maximum`  | 7       | + Navigator plugins, WebGL vendor masking, iframe fixes        |

```ruby
# Enable at initialization
browser = AgentFerrum::Browser.new(stealth: :maximum)

# Or switch dynamically
browser.stealth(:moderate)
browser.navigate("https://bot-detection-site.com")
```

## Downloads

```ruby
browser.download_path = "/tmp/downloads"
browser.click("@e5")  # Click a download link

filepath = browser.wait_for_download(timeout: 30)
puts filepath  # => "/tmp/downloads/report.pdf"

# Or wait for a specific filename
filepath = browser.wait_for_download(filename: "report.pdf", timeout: 60)
```

## Snapshot Format

The snapshot output is designed for AI consumption. Here's the structure:

```
# Page Title
URL: https://example.com/page

## Interactive Elements
@e1: [button] "Submit"
@e2: [textbox] "Email" value=""
@e3: [link] "Home" href="/"
@e4: [checkbox] "Remember me" checked=true
@e5: [combobox] "Country"
@e6: [link] "Sign up" href="/register"

## Page Content
# Welcome

Please fill in your details below.

| Field | Required |
|-------|----------|
| Email | Yes |
| Name  | No |

[Terms of Service](/tos)
```

**Supported interactive roles:** button, link, textbox, checkbox, radio, combobox, menuitem, tab, slider, spinbutton, searchbox, switch, option, listbox, menu, menubar.

**Element properties** included when present: `value`, `disabled`, `required`, `checked`, `selected`, `readonly`.

## API Reference

### Navigation

| Method          | Description      |
| --------------- | ---------------- |
| `navigate(url)` | Navigate to URL  |
| `back`          | Go back          |
| `forward`       | Go forward       |
| `refresh`       | Reload page      |
| `current_url`   | Current page URL |
| `title`         | Page title       |

### Content Extraction

| Method               | Returns             | Description                                          |
| -------------------- | ------------------- | ---------------------------------------------------- |
| `snapshot`           | `Snapshot`          | Full hybrid snapshot (accessibility tree + markdown) |
| `page_markdown`      | `String`            | Markdown of visible content only                     |
| `accessibility_tree` | `AccessibilityTree` | Interactive elements with refs                       |

### Actions

| Method                  | Description                              |
| ----------------------- | ---------------------------------------- |
| `click(target)`         | Click element (ref, CSS, XPath, or Hash) |
| `fill(target, value)`   | Fill text field                          |
| `select(target, value)` | Select dropdown option                   |
| `hover(target)`         | Hover over element                       |
| `type_text(text)`       | Type text via keyboard                   |

**Target resolution:** `"@e1"` (ref) > `{css: ".btn"}` / `{xpath: "//a"}` (Hash) > `"//*[@id='x']"` (XPath string starting with `/`) > `"button.submit"` (CSS string).

### Waiting

| Method                | Description                     |
| --------------------- | ------------------------------- |
| `wait_for(css:)`      | Wait for CSS selector           |
| `wait_for(xpath:)`    | Wait for XPath                  |
| `wait_for(text:)`     | Wait for text content           |
| `wait_for { block }`  | Wait for block to return truthy |
| `wait_for_navigation` | Wait for page idle              |

### Utilities

| Method                     | Description                       |
| -------------------------- | --------------------------------- |
| `evaluate(js)`             | Execute JavaScript, return result |
| `screenshot(path:, full:)` | Take screenshot                   |
| `quit`                     | Close browser                     |

## AI Agent Integration Example

Here's how an AI agent loop might use AgentFerrum:

```ruby
browser = AgentFerrum::Browser.new(stealth: :moderate)

# Agent navigates
browser.navigate("https://shop.example.com")

# Agent gets compact page representation
snap = browser.snapshot
# => Send snap.to_s to LLM (compact snapshot)

# LLM decides to search for a product
browser.fill("@e3", "wireless headphones")
browser.click("@e4")  # Search button

# Agent refreshes snapshot after action
browser.wait_for(css: ".results")
snap = browser.snapshot
# => Updated snapshot with search results

# LLM picks a product
browser.click("@e7")  # Product link

# Continue the loop...
browser.quit
```

## Development

```bash
git clone https://github.com/Alqemist-labs/agent_ferrum
cd agent_ferrum
bundle install

# Run unit tests
bundle exec rake test

# Run integration tests (requires Chrome)
bundle exec rake integration
```

## Contributing

Bug reports and pull requests are welcome on GitHub.

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## See Also

- [Ferrum](https://github.com/rubycdp/ferrum) -- The Chrome headless Ruby library this gem is built on
- [agent-browser](https://github.com/vercel-labs/agent-browser) -- Vercel's CLI for AI browser automation (accessibility tree + refs concept)
- [Crucible](https://github.com/joshfng/crucible) -- Ruby MCP server for browser automation with stealth mode
- [FerrumMCP](https://github.com/Eth3rnit3/FerrumMCP) -- MCP server for Ferrum with AI agent integration
- [RubyLLM::Tribunal](https://github.com/Alqemist-labs/ruby_llm-tribunal) -- LLM evaluation framework for Ruby
