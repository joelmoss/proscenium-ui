---
name: gen-test
description: Generate Minitest spec tests for a Proscenium::UI component
---

# Generate Test

Generate tests for a Proscenium::UI component following project test conventions.

## Arguments

- `target` (required): Component class name or file path (e.g., `Flash`, `breadcrumbs`, `lib/proscenium/ui/flash.rb`)

## Instructions

1. Read the component source to understand its properties, custom elements, and behaviour.

2. Read `test/test_helper.rb` to understand the test setup.

3. Read existing tests in `test/proscenium/ui/` for style reference.

4. Create or update the test file at `test/proscenium/ui/<name>_test.rb`.

## Test Conventions

- **Framework**: Minitest with spec-style syntax (`describe`/`it` blocks)
- **Assertions**: Capybara matchers (`assert_selector`, `assert_no_selector`, `find`, `assert_element`)
- **File header**: Always include `# frozen_string_literal: true` and `require 'test_helper'`
- **Top-level describe**: Use the full class constant (e.g., `describe Proscenium::UI::Flash do`)
- **render_subject**: Call at class level to declare the default render. Pass props as arguments.
- **context blocks**: Use `context 'description'` (aliased from `with`) for variant scenarios
- **Nested render_subject**: Call inside `context` blocks with different props to test variants
- **page/subject**: Returns the Capybara node of the rendered component
- **html**: Returns raw HTML string
- **controller**: Access the test controller for setting instance variables or flash
- **Asset sideloading**: Test with `Proscenium::Importer.imported.keys` and the `COMPONENTS_PATH` constant

## What to Test

1. **Renders the custom element** (e.g., `assert_element 'pui-flash'`)
2. **Side loads expected assets** (CSS, JS)
3. **Default prop values** render correctly
4. **Custom prop values** change output as expected
5. **Conditional rendering** (`render?` method if present)
6. **Content/slots** if the component yields to a block
7. **Data attributes** are set correctly
8. **Edge cases**: empty/nil props, boundary conditions

## Example

```ruby
# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::Flash do
  render_subject

  it 'side loads CSS' do
    render_subject

    assert_equal ["#{COMPONENTS_PATH}/flash/index.js",
                  "#{COMPONENTS_PATH}/flash/index.css"],
                 Proscenium::Importer.imported.keys
  end

  it 'renders custom element' do
    assert_element 'pui-flash'
  end

  context 'with flash messages' do
    before do
      controller.flash.now[:foo] = 'bar'
    end

    it 'assigns data attribute' do
      assert_equal 'bar', find('pui-flash')['data-flash-foo']
    end
  end
end
```
