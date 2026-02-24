# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Proscenium::UI is a Ruby gem providing a UI component library for Rails applications. Components are built with Phlex for HTML rendering, CSS Modules for scoped styling, and ES6 modules for JavaScript interactivity. Bundled by [Proscenium](https://proscenium.rocks).

## Commands

- **Run all tests:** `bin/rails test`
- **Run a single test file:** `bin/rails test test/proscenium/ui/form_test.rb`
- **Run a single test by line:** `bin/rails test test/proscenium/ui/form_test.rb:42`
- **Lint:** `bin/rubocop`
- **Lint with auto-fix:** `bin/rubocop -A`
- **Dev server:** `bin/rails server`
- **Install dependencies:** `bundle install && pnpm install`

## Architecture

### Component Pattern

All components inherit from `Proscenium::UI::Component`, which extends `Phlex::HTML` with:
- `Literal::Properties` for typed property definitions
- `Proscenium::Phlex::Sideload` for automatic JS/CSS asset loading
- `Proscenium::Phlex::CssModules` for scoped CSS class names

Each component lives in `lib/proscenium/ui/` with co-located assets:
```
lib/proscenium/ui/
  flash.rb                    # Component class
  flash/
    index.js                  # JavaScript module (auto-sideloaded)
    index.css                 # Global styles (auto-sideloaded)
    index.module.css          # CSS Modules (scoped classes)
```

### Main Components

- **Form** (`form.rb`, `form/`) — Form builder with field components in `form/fields/`. Fields inherit from `Fields::Base`. Translation support via `form/translation.rb`.
- **Breadcrumbs** (`breadcrumbs.rb`, `breadcrumbs/`) — Navigation breadcrumbs. Controllers mix in `Breadcrumbs::Control` to define breadcrumb trails.
- **Flash** (`flash.rb`, `flash/`) — Toast notifications using sourdough-toast JS library.
- **UJS** (`ujs/`) — Unobtrusive JavaScript helpers (data-confirm, data-disable-with).

### Testing

Tests use Minitest with spec-style syntax (`describe`/`it` blocks via maxitest and minitest-spec-rails). Capybara is used for DOM assertions on rendered components.

Key test helpers defined in `test/test_helper.rb`:
- `render_subject` (class method) — Declares what to render for the `describe` block. Accepts args/kwargs or a block returning args.
- `render_subject` (instance method) — Renders a component inline within a test.
- `page` / `subject` — Returns the Capybara node of the rendered component.
- `html` — Returns raw HTML string of the rendered component.

A dummy Rails app at `test/dummy/` provides the test environment.

## Code Style

- `unless`, `and`/`or`/`not`, and numbered block parameters are **disabled** (RuboCop enforced)
- Max line length: 100 characters
- Indentation style: `indented_internal_methods`
- Frozen string literals required in all Ruby files
- No `Style/Documentation` enforcement
