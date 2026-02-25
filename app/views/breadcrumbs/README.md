# Breadcrumbs

Navigation breadcrumbs that show the user's position in the application hierarchy. Renders using custom HTML elements (`pui-breadcrumbs`, `pui-breadcrumbs-home`, `pui-breadcrumbs-element`) with built-in responsive behaviour.

## Setup

Include the `Control` module in your controller:

```ruby
class ApplicationController < ActionController::Base
  include Proscenium::UI::Breadcrumbs::Control
end
```

Render the component in your view - ideally in your application layout:

```erb
<%= render Proscenium::UI::Breadcrumbs %>
```

## Adding Breadcrumbs

### In controller actions

```ruby
def show
  add_breadcrumb 'Users', '/users'
  add_breadcrumb 'John'              # text only, no link
end
```

### At the class level

Class-level calls use `before_action` under the hood, so they support filter options:

```ruby
class UsersController < ApplicationController
  add_breadcrumb 'Users', :users_path
  add_breadcrumb 'Admin', '/admin', only: :index
  prepend_breadcrumb 'Home', :root
end
```

## Method Signatures

```ruby
add_breadcrumb(name, path = nil, **options)
prepend_breadcrumb(name, path = nil, **options)
```

### `name`

| Type | Behaviour |
|------|-----------|
| `String` | Used as-is |
| `Symbol` | Calls a controller method of the same name |
| `Symbol` (`:@foo`) | Reads the controller instance variable |
| `Proc` | Evaluated in controller context |
| Object responding to `#for_breadcrumb` | That method is called |

### `path`

| Type | Behaviour |
|------|-----------|
| `nil` | Rendered as plain text (no link) |
| `String` | Passed to `url_for` |
| `Symbol` | Calls controller method if it exists, otherwise passed to `url_for` |
| `Symbol` (`:@foo`) | Reads the controller instance variable |
| `Array` | Passed to `url_for` (e.g. `[:user, :post]`) |
| `Proc` | Evaluated in controller context, result passed to `url_for` |

### `options`

At class level, `:if`, `:unless`, `:only`, and `:except` are extracted as `before_action` filter options. All remaining options are passed as HTML attributes to the `pui-breadcrumbs-element`:

```ruby
add_breadcrumb 'Users', '/users', class: 'active', data: { id: 1 }, only: :show
```

## Component Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `home_path` | `String`, `Symbol` | `:root` | Path for the home breadcrumb link |
| `with_home` | `Boolean` | `true` | Whether to show the home segment |

```ruby
render Proscenium::UI::Breadcrumbs.new(home_path: '/dashboard', with_home: false)
```

## Customising the Home Segment

Override `home_template` in a subclass:

```ruby
class MyBreadcrumbs < Proscenium::UI::Breadcrumbs
  def home_template
    super { 'Home' }  # replaces the SVG icon with text
  end
end
```

## Hiding Breadcrumbs

Set `@hide_breadcrumbs = true` in the controller to prevent rendering.

## Helper Methods

The `Control` module provides two helper methods available in views:

- `breadcrumbs_as_json` - Returns breadcrumbs as an array of `{ name:, path: }` hashes (path is `nil` for the current page).
- `breadcrumbs_for_title(primary: false)` - Returns breadcrumb names formatted for a page title. Pass `primary: true` to get only the last breadcrumb.

## CSS Custom Properties

Style breadcrumbs by setting these properties on `pui-breadcrumbs` or any ancestor:

| Property | Default | Description |
|----------|---------|-------------|
| `--puiBreadcrumbs--link-color` | `LinkText` | Link colour |
| `--puiBreadcrumbs--link-hover-color` | `HighlightText` | Link hover colour |
| `--puiBreadcrumbs--separator-color` | `GrayText` | Separator colour |
| `--puiBreadcrumbs--separator` | chevron SVG | Separator mask image |

## Responsive Behaviour

- **Desktop** (>426px): All breadcrumbs shown with separators.
- **Mobile** (<=426px): Only the second-to-last breadcrumb is shown with a back arrow, acting as a "back" link.
