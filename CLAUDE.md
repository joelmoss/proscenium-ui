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
- **Combobox** (`combobox.rb`, `combobox/`) — Searchable select using WAI-ARIA combobox pattern. Custom element `<pui-combobox>` with static filtering, async search, and multi-select with tags.

### Demo/Docs App

The main Rails app (`app/`) is a component playground (like Storybook/Lookbook):
- **Navigation** (`app/components/navigation.rb`) auto-discovers controllers by scanning `app/controllers/` for `*_controller.rb` files, and sub-pages from view files in `app/views/<controller>/`.
- **Adding a new component demo** requires: a controller (e.g. `combobox_controller.rb`), view files per example (e.g. `app/views/combobox/basic.rb`), routes for each action, and a `README.md` for the landing page.
- **Views** are Phlex classes inheriting from `Views::Application` with `Phlexible::Rails::AutoLayout`.
- **Landing pages** are handled by `ApplicationController#landing` which renders the controller's `README.md`.
- **Preview pages** render in an iframe via `/bare/` prefix routes.

### Design Philosophy

- Components are **unstyled by default** — use browser defaults, not opinionated styling.
- CSS custom properties (e.g. `--pui-input-border`) allow opt-in theming but have no defaults set.
- Component CSS lives in `@layer pui` to keep specificity low.
- Use system colors (`Canvas`, `SelectedItem`, `SelectedItemText`) over hardcoded values for light/dark mode compatibility.
- Use `em` units (not `rem`) so component sizing is relative to its own font size.
- Use `@media (pointer: coarse)` for touch adaptations rather than viewport breakpoints.

### Testing

Tests use Minitest with spec-style syntax (`describe`/`it` blocks via maxitest and minitest-spec-rails). Capybara is used for DOM assertions on rendered components.

Key test helpers defined in `test/test_helper.rb`:
- `render_subject` (class method) — Declares what to render for the `describe` block. Accepts args/kwargs or a block returning args.
- `render_subject` (instance method) — Renders a component inline within a test.
- `page` / `subject` — Returns the Capybara node of the rendered component.
- `html` — Returns raw HTML string of the rendered component.

## Code Style

- `unless`, `and`/`or`/`not`, and numbered block parameters are **disabled** (RuboCop enforced)
- Max line length: 100 characters
- Indentation style: `indented_internal_methods`
- Frozen string literals required in all Ruby files
- No `Style/Documentation` enforcement
