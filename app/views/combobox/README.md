# Combobox

A searchable select replacement using the WAI-ARIA combobox pattern. Works both as a standalone component and as a form field. Built with a custom element (`<pui-combobox>`) and zero JavaScript dependencies.

## Standalone Usage

```ruby
# Simple string options
render Proscenium::UI::Combobox.new(
  name: 'color',
  placeholder: 'Pick a colour...',
  options: %w[Red Green Blue]
)

# Label/value pairs with a pre-selected value
render Proscenium::UI::Combobox.new(
  name: 'country',
  placeholder: 'Select country...',
  options: [['United States', 'us'], ['Canada', 'ca']],
  value: 'us'
)

# Multi-select with tags
render Proscenium::UI::Combobox.new(
  name: 'tags',
  placeholder: 'Add tags...',
  options: %w[Ruby Rails JavaScript],
  multiple: true,
  value: %w[Ruby Rails]
)

# Async search (fetches JSON from a URL)
render Proscenium::UI::Combobox.new(
  name: 'user_id',
  src: '/api/users',
  placeholder: 'Search users...',
  min_chars: 2
)
```

## Form Field Usage

```ruby
Proscenium::UI::Form.new(@project) do |f|
  f.combobox_field :status, options: %w[draft active archived]
  f.combobox_field :assignee_id, src: '/api/users', placeholder: 'Search...'
  f.combobox_field :tags, multiple: true
  f.submit 'Save'
end
```

Enum and association options are auto-detected when no `options` or `src` is provided.

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `String` | `nil` | Hidden input name for form submission |
| `options` | `Array` | `[]` | Static options — strings, `[label, value]` pairs, or `{label:, value:}` hashes |
| `src` | `String` | `nil` | URL for async search (`GET <src>?q=<term>`, expects `[{label:, value:}]` JSON) |
| `multiple` | `Boolean` | `false` | Enable multi-select with tags |
| `placeholder` | `String` | `nil` | Input placeholder text |
| `value` | `String`, `Array` | `nil` | Current value(s) |
| `min_chars` | `Integer` | `0` | Minimum characters before filtering/fetching |
| `debounce` | `Integer` | `300` | Debounce delay in ms for async requests |
| `disabled` | `Boolean` | `false` | Disable the combobox |
| `selected_options` | `Array` | `[]` | Pre-rendered tags for async multi-select: `[{label:, value:}]` |

## Keyboard Navigation

| Key | Action |
|-----|--------|
| `ArrowDown` | Open listbox / move to next option |
| `ArrowUp` | Move to previous option |
| `Home` / `End` | Jump to first / last option |
| `Enter` | Select the active option |
| `Escape` | Close the listbox |
| `Backspace` | Remove last tag (multi-select, when input is empty) |

## Events

The component dispatches a `combobox:change` event on value changes:

```javascript
document.querySelector('pui-combobox').addEventListener('combobox:change', (e) => {
  console.log(e.detail.value) // string (single) or array (multi)
})
```

## Async Endpoint

When `src` is set, the component sends a `GET` request with a `q` query parameter and expects a JSON array:

```
GET /api/users?q=ali
→ [{"label": "Alice", "value": "1"}, {"label": "Alicia", "value": "2"}]
```

## CSS Custom Properties

Style the combobox by setting these properties on `pui-combobox` or any ancestor:

| Property | Default | Description |
|----------|---------|-------------|
| `--pui-combobox-active-bg` | `SelectedItem` | Active option background |
| `--pui-combobox-active-color` | `SelectedItemText` | Active option text colour |

The input uses default browser styling. The listbox inherits the shared form custom properties (`--pui-input-border`, `--pui-input-border-radius`, `--pui-input-background-color`) when set.
