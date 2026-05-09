# DropdownMenu

An action menu built on top of [Dropdown](../dropdown/), following the WAI-ARIA menu pattern. Adds full keyboard navigation, typeahead, and an `item` helper for rendering menu entries. Renders a `<pui-dropdown-menu>` custom element.

## Usage

Subclass `DropdownMenu` and implement `trigger_template` and `menu_template`:

```ruby
class AccountMenu < Proscenium::UI::DropdownMenu
  def trigger_template
    'Account'
  end

  def menu_template
    item(href: '/profile')   { 'Profile' }
    item(href: '/settings')  { 'Settings' }
    item                     { 'Invite teammates' }   # button
    hr                                                # separator
    item(disabled: true)     { 'Billing (coming soon)' }
    item(href: '/sign_out')  { 'Sign out' }
  end
end

render AccountMenu.new
```

Or inline:

```ruby
cls = Class.new Proscenium::UI::DropdownMenu do
  def trigger_template = 'Account'
  def menu_template
    item(href: '#') { 'Profile' }
    item            { 'Sign out' }
  end
end

render cls.new
```

## Required Methods

| Method | Description |
|--------|-------------|
| `trigger_template` | Renders the contents of the trigger |
| `menu_template`    | Renders the contents of the menu (use `item` and `hr`) |

`dropdown_template` is provided by `DropdownMenu` and forwards to `menu_template`, so you don't implement it directly.

## The `item` Helper

```ruby
item(href: nil, disabled: false, **attrs, &block)
```

Renders one menu entry. The element type depends on the arguments:

| Args | Element | Notes |
|------|---------|-------|
| `disabled: true` | `<span aria-disabled="true">` | Skipped by keyboard nav and click handling |
| `href: "..."` | `<a href="...">` | Use for navigation |
| neither | `<button type="button">` | Use for actions |

All entries get `role="menuitem"` and `tabindex="-1"`. Extra HTML attributes pass through:

```ruby
item(href: '/users', class: 'highlight', data: { turbo_frame: 'main' }) { 'Users' }
```

Use `hr` (a Phlex helper) to render a separator between groups of items.

## Behaviour

`DropdownMenu` inherits all of `Dropdown`'s behaviour (popover, positioning, outside-click dismiss, return-focus-to-trigger) and adds:

- The first enabled item is focused automatically when the menu opens.
- Clicking an enabled item closes the menu (disabled items are ignored).
- Tab closes the menu instead of moving focus through items.

## Keyboard Navigation

| Key | Action |
|-----|--------|
| `Enter` / `Space` (on trigger) | Open the menu |
| `ArrowDown` | Focus next item (wraps) |
| `ArrowUp` | Focus previous item (wraps) |
| `Home` | Focus first item |
| `End` | Focus last item |
| Any printable character | Typeahead — focuses the next item whose text starts with the buffered keys (resets after 500ms) |
| `Tab` | Close the menu |
| `Escape` | Close the menu (handled by the popover) |

Disabled items are skipped by all keyboard navigation and typeahead.

## ARIA

| Element | Attributes |
|---------|------------|
| `<pui-dropdown-trigger>` | `role="button"`, `aria-haspopup="menu"`, `aria-expanded`, `aria-controls` |
| `<pui-dropdown-container>` | `role="menu"`, `popover="auto"` |
| Menu items | `role="menuitem"`, `tabindex="-1"`, `aria-disabled="true"` when disabled |

## CSS Custom Properties

`DropdownMenu` inherits all of [Dropdown's properties](../dropdown/README.md#css-custom-properties), and adds:

| Property | Default | Description |
|----------|---------|-------------|
| `--pui-dropdown-menu-item-hover-bg` | `color-mix(in srgb, CanvasText 8%, transparent)` | Hover background for items |
| `--pui-dropdown-menu-item-active-bg` | `SelectedItem` | Background of the focused item |
| `--pui-dropdown-menu-item-active-color` | `SelectedItemText` | Text colour of the focused item |
| `--pui-dropdown-menu-item-disabled-opacity` | `0.5` | Opacity of disabled items |
