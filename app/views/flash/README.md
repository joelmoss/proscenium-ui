# Flash

Toast notifications powered by [sourdough-toast](https://github.com/imothee/sourdough-toast). Renders a `<pui-flash>` custom element that automatically displays Rails flash messages as toast notifications.

## Usage

Render the component in your layout or view:

```ruby
render Proscenium::UI::Flash
```

Flash messages set in the controller are automatically picked up:

```ruby
class PostsController < ApplicationController
  def create
    @post = Post.create(post_params)
    redirect_to @post, notice: 'Post created successfully.'
  end

  def destroy
    @post.destroy
    redirect_to posts_path, alert: 'Post has been deleted.'
  end
end
```

## How It Works

The component renders a `<pui-flash>` custom element with each flash key as a `data-flash-*` attribute:

```html
<pui-flash data-flash-notice="Post created successfully."></pui-flash>
```

The custom element initialises sourdough-toast and maps flash types to toast styles:

| Flash Type | Toast Style |
|------------|-------------|
| `notice`   | `success`   |
| `alert`    | `warning`   |

## Turbo / HTMX Support

The component also watches for changes to a `<meta name="rails:flashes">` tag in the document head. When Turbo (or similar) updates the meta tag, new toasts are shown automatically:

| Flash Type | Toast Style |
|------------|-------------|
| `notice`   | `success`   |
| `alert`    | `error`     |

## Toast Options

The underlying sourdough-toast instance is configured with:

- **Rich colours** enabled
- **Position:** bottom-center
