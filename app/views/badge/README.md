# Badge

A purely presentational component for displaying short text labels such as status indicators, categories, or counts. Renders a `<pui-badge>` custom element.

## Usage

```ruby
render Proscenium::UI::Badge.new("Active")
```

With variants:

```ruby
render Proscenium::UI::Badge.new("Error", variant: :danger)
render Proscenium::UI::Badge.new("OK", variant: :success)
```

With size variants:

```ruby
render Proscenium::UI::Badge.new("Small", size: :sm)
render Proscenium::UI::Badge.new("Large", size: :lg)
```

## Props

| Prop | Type | Default | Notes |
|------|------|---------|-------|
| `text` | `String` | required, positional | Badge text content |
| `variant` | Symbol | `:default` | `:default`, `:success`, `:warning`, `:danger`, `:info` |
| `size` | Symbol | `:md` | `:sm`, `:md`, `:lg` |

## CSS Custom Properties

| Property | Description |
|----------|-------------|
| `--puiBadge--bg` | Background color |
| `--puiBadge--color` | Text color |
| `--puiBadge--border` | Border shorthand (default: `1px solid`) |
| `--puiBadge--{type}-bg` | Type-specific background (e.g. `--puiBadge--success-bg`) |
| `--puiBadge--{type}-color` | Type-specific text color |
| `--puiBadge--{type}-border-color` | Type-specific border color |
