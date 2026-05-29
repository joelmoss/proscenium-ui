# Dropdown

A floating panel anchored to a trigger element. Built on the native popover API (with a fallback for unsupported browsers) and [Floating UI](https://floating-ui.com/) for positioning. Renders custom elements (`<pui-dropdown>`, `<pui-dropdown-trigger>`, `<pui-dropdown-container>`, `<pui-dropdown-body>`, `<pui-dropdown-arrow>`).

For a ready-made action menu with keyboard navigation, see [DropdownMenu](../dropdown_menu/).

## Usage

`Dropdown` is an abstract base. Each element is rendered by its own `*_template` method that emits the element with its default attributes and yields its content. Subclass it and override `trigger_template` and `body_template`, calling `super` with a block to fill them:

```ruby
class AccountDropdown < Proscenium::UI::Dropdown
  def trigger_template
    super { 'Open' }
  end

  def body_template
    super do
      h4 { 'Hello, World!' }
      a(href: '#') { 'Click me!' }
    end
  end
end

render AccountDropdown.new
```

You can also build an inline anonymous subclass when a one-off use is enough:

```ruby
cls = Class.new Proscenium::UI::Dropdown do
  def trigger_template = super { 'Open' }
  def body_template = super { p { 'Anything you like in here.' } }
end

render cls.new
```

## Template Methods

Each element has an overridable `*_template` method. Pass attributes to adjust the element and/or a block to fill it, e.g. `super(class: 'panel') { ... }`. Attributes you pass are merged over (and win against) the defaults.

| Method | Element | Default content |
|--------|---------|-----------------|
| `view_template` | `<pui-dropdown>` (the host) | the trigger + container structure |
| `trigger_template` | `<pui-dropdown-trigger>` (the clickable handle) | empty |
| `container_template` | `<pui-dropdown-container>` (the popover) | the body + arrow |
| `body_template` | `<pui-dropdown-body>` (the floating panel) | empty |
| `arrow_template` | `<pui-dropdown-arrow>` | — |

To scope the whole dropdown with one CSS-module class, add it to the host: `def view_template = super(class: :@menu)`. They're all Phlex methods, so the full Phlex DSL is available inside the blocks.

## Behaviour

- The trigger toggles the panel on click, `Enter`, or `Space`.
- The panel uses `popover="auto"`, so it appears in the top layer and the browser closes it on outside click and `Escape` (no JS needed for light dismiss).
- A blur of the entire window also closes the panel.
- Positioning is `bottom-start` with a 6px offset, auto-flipping when there isn't room, and an arrow that follows the trigger.
- When the panel closes, focus returns to the trigger if focus was inside the panel or on `document.body`.

## ARIA

| Element | Attributes |
|---------|------------|
| `<pui-dropdown-trigger>` | `role="button"`, `tabindex="0"`, `aria-haspopup="true"`, `aria-expanded`, `aria-controls` |
| `<pui-dropdown-container>` | `popover="auto"`, `id` (referenced by `aria-controls`) |

## CSS Custom Properties

Style the dropdown by setting these properties on `pui-dropdown` or any ancestor:

| Property | Default | Description |
|----------|---------|-------------|
| `--pui-dropdown-background` | `Canvas` | Panel background colour |
| `--pui-dropdown-color` | `CanvasText` | Panel text colour |
| `--pui-dropdown-border-color` | `color-mix(in srgb, CanvasText 20%, transparent)` | Panel + arrow border |
| `--pui-dropdown-shadow` | soft two-layer shadow | Panel `box-shadow` |
| `--pui-dropdown-max-height` | `min(20em, 70vh)` | Max height of the scrollable body |
