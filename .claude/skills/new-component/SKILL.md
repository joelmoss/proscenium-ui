---
name: new-component
description: Scaffold a new Proscenium::UI component with co-located assets
---

# New Component

Scaffold a new Proscenium::UI component following project conventions.

## Arguments

- `name` (required): Component name in snake_case (e.g., `date_picker`)

## Instructions

1. Ask for the component name if not provided as an argument.

2. Create the component class at `lib/proscenium/ui/<name>.rb`:

```ruby
# frozen_string_literal: true

module Proscenium::UI
  class <ClassName> < Component
    register_element :pui_<name>

    def view_template
      pui_<name> do
        # Component content
      end
    end
  end
end
```

Key conventions:
- Inherits from `Proscenium::UI::Component`
- Uses `register_element` with `pui_` prefix for custom HTML elements
- Uses `prop` from `Literal::Properties` for typed properties (e.g., `prop :label, String, default: -> { '' }`)
- Frozen string literal comment required

3. Create co-located asset directory at `lib/proscenium/ui/<name>/`:
   - `index.js` — ES6 module (auto-sideloaded)
   - `index.css` — Global styles (auto-sideloaded)
   - `index.module.css` — CSS Modules for scoped classes (optional, only if needed)

4. If the component uses CSS Modules, reference scoped classes with `class: :@class_name` in the Ruby template.

5. Create a test file at `test/proscenium/ui/<name>_test.rb`:

```ruby
# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::<ClassName> do
  render_subject

  it 'renders' do
    assert_selector 'pui-<name>'
  end
end
```

Test conventions:
- Uses Minitest spec-style (`describe`/`it`)
- `render_subject` declares what to render
- Uses Capybara `assert_selector` for DOM assertions

6. Create a demo view at `app/views/<name>/basic.rb` and controller at `app/controllers/<name>_controller.rb` for the dev server.

7. Add routes in `config/routes.rb` following the existing pattern:

```ruby
get :<name>, to: '<name>#landing'
get '<name>/basic', to: '<name>#basic'

# Inside scope path: :bare
get '<name>/basic', to: '<name>#basic'
```
