# WebComponent

The base class every Proscenium::UI custom element extends. Lives at `lib/proscenium/ui/web_component.js`. Subclass it in JavaScript to build your own custom elements with declarative event handling, DOM-driven targets, reactive values, and namespaced events.

## Why use it

Custom elements alone require a lot of imperative wiring: registration, attribute observation, event listeners that you have to remember to remove on disconnect, and ad-hoc patterns for talking to descendant elements. `WebComponent` collapses that boilerplate into five small conventions you'll see repeated across this library.

## Defining a component

Extend `WebComponent`, set a unique `componentName`, and call `register()`:

```javascript
import WebComponent from 'proscenium-ui/web_component'

class MyCounter extends WebComponent {
  static componentName = 'my-counter'
}

WebComponent.register(MyCounter)
```

Then use it in HTML:

```html
<my-counter></my-counter>
```

`register()` is idempotent — calling it twice is a no-op — and throws a `TypeError` if `componentName` is missing.

## Actions

Bind DOM events to instance methods declaratively. Set `static actions` to an object whose keys are event types and whose values are arrays of method names. Wire them up in HTML with `on-<event>="<method>"`:

```javascript
class MyCounter extends WebComponent {
  static componentName = 'my-counter'
  static actions = { click: ['increment', 'decrement'] }

  increment(event, target) { /* ... */ }
  decrement(event, target) { /* ... */ }
}
```

```html
<my-counter>
  <button on-click="decrement">−</button>
  <button on-click="increment">+</button>
</my-counter>
```

The handler receives the original `event` and the closest ancestor element carrying the matching `on-<event>` attribute (the click target itself may be a descendant of that ancestor — the helper walks up to find it). Supported event types: `click`, `focusin`, `keydown`, `keyup`, `change`, `submit`, `beforeinput`, `input`, `dragstart`, `dragover`, `drop`, `dragend`.

## Targets

Any element with a `data-target="name"` attribute is reachable via `$nameTarget` (first match) and `$nameTargets` (array of matches). The lookup is lazy — properties are resolved through a prototype `Proxy` each time you access them, so they always reflect the current DOM.

```html
<my-tabs>
  <button data-target="tab" data-id="overview">Overview</button>
  <button data-target="tab" data-id="details">Details</button>
  <div data-target="panel" data-id="overview">…</div>
  <div data-target="panel" data-id="details">…</div>
</my-tabs>
```

```javascript
class MyTabs extends WebComponent {
  showFirst() {
    this.$tabTargets[0].focus()        // array
    this.$panelTarget.hidden = false   // first match
  }
}
```

You can also override either property by assigning it on the instance — useful for caching expensive lookups.

## Values

Any element with `data-value="name"` exposes a reactive `nameValue` property. Reading it returns the element's text content; assigning to it updates the text content in place.

```html
<my-counter>
  <span data-value="count">0</span>
  <button on-click="increment">+</button>
</my-counter>
```

```javascript
increment() {
  this.countValue = String(Number(this.countValue) + 1)
}
```

## Observed attributes

Any attribute listed in `static observedAttributes` will trigger a method named after the attribute in camelCase, suffixed with `Changed`. For example, `data-open` calls `dataOpenChanged(oldValue, newValue)`:

```javascript
class MyDisclosure extends WebComponent {
  static componentName = 'my-disclosure'
  static observedAttributes = ['data-open']

  dataOpenChanged(oldValue, newValue) {
    this.$panelTarget.hidden = newValue !== 'true'
  }
}
```

If you extend a class that also declares `observedAttributes`, the parent's list is merged in at registration time so the parent's attribute callbacks keep firing.

## Mixins

Use `WebComponent.withMixins(...)` to compose behaviour across classes. Each mixin is a function that takes a superclass and returns a subclass. Mixins are applied in reverse argument order, so the leftmost mixin ends up outermost in the prototype chain. Each mixin's `observedAttributes` contribution is merged into the result.

```javascript
function Disableable(superClass) {
  return class extends superClass {
    static observedAttributes = ['disabled']
    disabledChanged(_, value) { /* ... */ }
  }
}

class MyButton extends WebComponent.withMixins(Disableable) {
  static componentName = 'my-button'
}
```

## Events: listen, dispatch, handleEvent

`WebComponent` provides three event helpers that handle namespacing and lifetime cleanup so you don't have to.

### `dispatch(eventName, { detail, cancelable } = {})`

Fires a `CustomEvent` with `bubbles: true, composed: true`. Three forms:

| Call | Resolved type | Fires on |
|------|---------------|----------|
| `dispatch(':opened')` | `<componentName>:opened` | `this` (bubbles) |
| `dispatch('my-counter:opened')` | unchanged | `this` if prefix matches `componentName`, else `document` |
| `dispatch('save')` | unchanged | `document` |

The leading-colon shorthand is the canonical way to emit a component-namespaced event — listeners on the document or any ancestor will receive it because the event bubbles.

### `listen(eventName, callback?, options?)`

Wraps `addEventListener` with the same prefix conventions:

| Prefix | Listens on |
|--------|------------|
| `':event'` | `document` (resolved to `<componentName>:event`) |
| `'^event'` | `document` (caret stripped) |
| `'a:b'` (any colon) | `document` |
| anything else | `this` |

If you omit the callback, `listen` uses the component itself as the listener and `handleEvent` takes over (see below). You can also pass an options object as the second argument when the callback would have been `this`:

```javascript
this.listen(':opened', { once: true })
```

`unlisten(eventName, callback?, options?)` mirrors `listen` and removes the listener.

### `handleEvent(event)`

When a component is its own listener, `handleEvent` routes the event to a method named after the event type, capitalised and prefixed with `on`. For namespaced events the prefix is stripped first, so `pui-counter:opened` calls `onOpened`, and a plain `click` calls `onClick`. Returns `true` if it found a method to call — useful for subclasses overriding it:

```javascript
handleEvent(event) {
  if (super.handleEvent(event)) return
  // …custom fallback…
}
```

## Selector helpers

Two short methods you'll see throughout: `this.$(selector)` is `querySelector` scoped to the component, and `this.$$(selector)` is `querySelectorAll` scoped to the component, returned as a plain `Array`.

## Lifecycle

`WebComponent`'s `connectedCallback` wires up actions and creates value properties. `disconnectedCallback` removes the action listeners. If you override either, call `super` first.
