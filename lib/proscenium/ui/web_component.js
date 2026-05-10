const debug = proscenium.env.RAILS_ENV === 'development'

// Supported action events
const actionEvents = new Set([
  'click',
  'focusin',
  'keydown',
  'keyup',
  'change',
  'submit',
  'beforeinput',
  'input',
  'dragstart',
  'dragover',
  'drop',
  'dragend'
])

/**
 * Extend any component with the ability to register itself as a custom element and listen for
 * actions defined in the HTML.
 *
 * ### Usage
 *
 * A basic component can be defined and registered like this, where the required `componentName`
 * static variable is a unique name for the component:
 *
 * ```javascript
 * Component.register(
 *   class extends WebComponent {
 *     static componentName = 'my-component'
 *   }
 * )
 * ```
 *
 * Registering a component is required to use it in HTML, and is atomic, so it can be called
 * multiple times without side effects.
 *
 * Finally insert your component into the page, using the `componentName` you gave it earlier:
 *
 * ```html
 * <my-component></my-component>
 * ```
 *
 * ### Actions
 *
 * WebComponent provides the ability to define 'actions' that can be triggered by events on the
 * component. Actions are a convenient way to define events directly in the HTML, without needing to
 * manually add and remove event listeners.
 *
 * Actions are defined as an object with event types as keys and an array of action names as values.
 * The action names are the names of the methods on the component that will be called when the event
 * is triggered.
 *
 * ```javascript
 * Component.register(
 *   class extends WebComponent {
 *     static componentName = 'my-component'
 *     static actions = { click: ['doSomething'] }
 *
 *     doSomething(event, target) {
 *       console.log('Hello, world!')
 *     }
 *   }
 * )
 * ```
 *
 * The above component can be used as follows, where `doSomething` will be called when the button is
 * clicked. The `doSomething` method will receive the event that triggered the action and the target
 * of the event as arguments.
 *
 * ```html
 * <my-component>
 *   <button on-click="doSomething">Click me</button>
 * </my-component>
 * ```
 *
 * See `actionEvents` for the supported event types.
 *
 * ### Targets
 *
 * All elements with a `data-target` attribute are available via instance properties. For example,
 * an element with `data-target="menu"` will create `$menuTarget` and `$menuTargets` properties.
 * Where `$menuTarget` will be the first matching element, and `$menuTargets` will be an array of
 * all matching elements.
 *
 * These properties are created on demand via a Proxy, so they are "live" — they always reflect the
 * current DOM state. You can override a target property by explicitly setting it on the instance.
 *
 * ### Values
 *
 * All elements with a `data-value` attribute are available via instance properties. For example, an
 * element with `data-value="count"` will create a `countValue` property. This property is reactive,
 * so setting it will update the text content of the element, and changing the text content of the
 * element will update the property.
 *
 * ### Observed Attributes
 *
 * Any attributes defined in the static `observedAttributes` array will be observed for changes as
 * per the custom elements standard, and when they change, a method with the name of the attribute
 * in camelCase with 'Changed' appended will be called. For example, an attribute of `data-open`
 * will call the method `dataOpenChanged(oldValue, newValue)` when it changes.
 */
class WebComponent extends HTMLElement {
  /**
   * Register the component as a defined custom element.
   *
   * @param {Class} klass - The class to register as a custom element. If not given, the class this
   *   method is called on will be registered.
   * @param {...Function} extendables - Any mixins to apply to the class before registering it.
   *   Deprecated in favour of `withMixins()` which correctly handles the order of mixins in a class
   *   hierarchy.
   * @throws {TypeError} If the static variable `componentName` is not defined.
   */
  static register(klass, ...extendables) {
    function defineCustomElement(klass) {
      if (klass.componentName === undefined) {
        throw new TypeError('`componentName` must be defined when extending WebComponent')
      }

      if (!customElements.get(klass.componentName)) {
        debug && console.debug(`[WebComponent] Registered: ${klass.componentName}`)
        customElements.define(klass.componentName, klass)
      }
    }

    if (klass === undefined) {
      defineCustomElement(this)
    } else {
      if (extendables.length > 0) {
        console.warn(
          'Passing mixins to WebComponent.register()` is deprecated. Please use `WebComponent.withMixins()` instead to ensure correct mixin order.'
        )

        extendables.forEach(extendable => {
          klass = extendable(klass)
        })
      }

      // If the class being registered has its own observedAttributes, we need to merge them with
      // the ones from WebComponent. This is because when a class defines its own
      // observedAttributes, it completely overrides the parent's value, which for some mixins,
      // means the mixin won't work if the property is not merged.
      if (Object.getPrototypeOf(klass).observedAttributes) {
        klass.observedAttributes = [
          ...klass.observedAttributes,
          ...Object.getPrototypeOf(klass).observedAttributes
        ]
      }

      defineCustomElement(klass)
    }
  }

  /**
   * A helper method for applying mixins to a WebComponent class. Mixins should be functions that
   * take a class and return a new class that extends it. For example:
   *
   * ```javascript
   * function MyMixin(superClass) {
   *   return class extends superClass {
   *     myMethod() {
   *       console.log('Hello, world!')
   *     }
   *   }
   * }
   * ```
   *
   * You can then apply this mixin to a WebComponent class like this:
   *
   * ```javascript
   * class MyComponent extends WebComponent.withMixins(MyMixin) {
   *   static componentName = 'my-component'
   * }
   * ```
   *
   * You can apply multiple mixins by passing them as additional arguments to `withMixins()`, and
   * they will be applied in reverse order. For example:
   *
   * ```javascript
   * class MyComponent extends WebComponent.withMixins(MyMixin1, MyMixin2) {
   *   static componentName = 'my-component'
   * }
   * MyComponent.register()
   * ```
   *
   * @param {...Function} mixins - The mixins to apply to the class.
   *
   * @returns {Class} A new class that extends the original class with the mixins applied.
   */
  static withMixins(...mixins) {
    let observedAttributes = []
    let klass = this

    mixins.reverse().forEach(mixin => {
      klass = mixin(klass)
      if (klass.observedAttributes) {
        observedAttributes = [...observedAttributes, ...klass.observedAttributes]
      }
    })

    klass.observedAttributes = observedAttributes

    return klass
  }

  static actions = []

  #hasActions = new Set()

  componentName = this.constructor.componentName

  constructor() {
    super()
    this.actions = this.constructor.actions
  }

  connectedCallback() {
    this.#listenForActions()
    this.#createValues()
  }

  disconnectedCallback() {
    this.#unlistenForActions()
  }

  attributeChangedCallback(name, oldValue, newValue) {
    const callbackName = `${camelCase(name)}Changed`
    if (callbackName in this) {
      this[callbackName](oldValue, newValue)
    }
  }

  /**
   * Listen for an event on this component with the name of `eventName`. This accepts the same
   * arguments as `addEventListener`, but with a few niceties.
   *
   * If `eventName` is prefixed with a colon, the component name will be prepended to it. This is
   * useful for namespacing events to the component. For example, an event name of ':clickOutside'
   * on a component with name of 'my-component' will be converted to 'my-component:clickOutside'.
   * All other event names are passed through untouched.
   *
   * If `eventName` is prefixed with a caret, it will be listened for on the document instead of the
   * component, but the callback will still be on the component instance. For example, `^click` will
   * listen for 'click' events on the document, but call the callback on the component instance.
   * This is a convenient syntax for listening globally - on the document, while still keeping the
   * callback logic within the component.
   *
   * Any event that contains a colon will be listened for on the `document` instead of the
   * component, which means you can use this same listen/dispatch API within any component to listen
   * for events on any other component.
   *
   * If `callback` is not provided, the component will listen for the event on itself and call the
   * `handleEvent` method when the event is triggered (as per the `addEventListener` logic).
   *
   * If `callback` is not given as the second argument, you can pass the options object as the
   * instead. For example: `listen('click', { capture: true })`.
   *
   * If `handleEvent` is used, and the event is namespaced to the component, the method with the
   * same name as the event type will be called. For example, if the event type is
   * 'my-component:click', the method `onClick` will be called. This avoids you having to define
   * `handleEvent`, and simply define the methods for each event type.
   *
   * @param {String} eventName
   * @param {Function | Object#handleEvent | Object} callback - The function to call when the event
   *   is triggered. Defaults to `this`.
   * @param {Object} options - Options to pass to `addEventListener`
   */
  // eslint-disable-next-line no-unused-vars
  listen(eventName, callback, options = {}) {
    const listenerArgs = this.#buildEventListenerArguments(...arguments)

    if (listenerArgs[0].startsWith('^')) {
      listenerArgs[0] = listenerArgs[0].slice(1)
      document.addEventListener(...listenerArgs)
    } else if (listenerArgs[0].includes(':')) {
      document.addEventListener(...listenerArgs)
    } else {
      this.addEventListener(...listenerArgs)
    }
  }

  /**
   * Unlisten for an event on this component with the name of `eventName`. This accepts the same
   * arguments as the `listen()` method above.
   *
   * @param {String} eventName
   * @param {Function | Object#handleEvent | Object} callback - The function to call when the event
   *   is triggered.
   * @param {Object} options - Options to pass to `addEventListener`
   */
  // eslint-disable-next-line no-unused-vars
  unlisten(eventName, callback, options = {}) {
    const listenerArgs = this.#buildEventListenerArguments(...arguments)

    if (listenerArgs[0].startsWith('^')) {
      listenerArgs[0] = listenerArgs[0].slice(1)
      document.removeEventListener(...listenerArgs)
    } else if (listenerArgs[0].includes(':')) {
      document.removeEventListener(...listenerArgs)
    } else {
      this.removeEventListener(...listenerArgs)
    }
  }

  /**
   * Dispatch a custom event on this component. This is a wrapper around the native `dispatchEvent`
   * method, but with some niceties.
   *
   * If `eventName` is prefixed with a colon, the component name will be prepended to it. This is
   * useful for namespacing events to the component. For example, an event name of ':clickOutside'
   * on a component with name of 'my-component' will be converted to 'my-component:clickOutside'.
   * All other event names are passed through untouched.
   *
   * If the converted `eventName` is prefixed with the current component name and colon, events will
   * be dispatched on the component. Eg. `my-component:clickOutside` will be dispatched on the
   * `my-component` instance.
   *
   * @param {String} eventName - The name of the event to dispatch.
   * @param {Object} options - Options for the event.
   * @param {boolean} options.cancelable - Whether the event is cancelable.
   * @param {any} options.detail - The detail to include with the event.
   *
   * @returns {CustomEvent} The dispatched event.
   */
  dispatch(eventName, { cancelable, detail } = {}) {
    if (eventName.startsWith(':')) {
      eventName = this.constructor.componentName + eventName
    }

    const event = new CustomEvent(eventName, {
      bubbles: true,
      composed: true,
      cancelable,
      detail
    })

    if (eventName.startsWith(`${this.constructor.componentName}:`)) {
      this.dispatchEvent(event)
    } else {
      document.dispatchEvent(event)
    }

    return event
  }

  /**
   * Handle an event triggered on this component. This is called automatically when an event is
   * triggered on the component, and can be overridden to provide custom logic.
   *
   * If a function with the same name as the event type exists on the component, it will be called.
   * For example, if the event type is 'click' or 'my-component:click', the method `onClick` will be
   * called.
   *
   * @param {Event} event - The event that was triggered.
   *
   * @returns {boolean} Whether the event was handled. This allows you to override this method while
   *   still calling the parent method. For example: `super.handleEvent(event) || ...`
   */
  handleEvent(event) {
    let { type } = event
    if (type.includes(':')) {
      type = type.slice(type.indexOf(':') + 1)
    }

    if (this['on' + capitalize(type)]) {
      this['on' + capitalize(type)](event)

      return true
    }

    return false
  }

  $(x) {
    return this.querySelector(x)
  }

  $$(x) {
    return Array.from(this.querySelectorAll(x))
  }

  // Create reactive value properties
  #createValues() {
    this.querySelectorAll('[data-value]').forEach($ele => {
      const prop = `${$ele.dataset.value}Value`
      if (!(prop in this)) {
        Object.defineProperty(this, prop, {
          get: () => $ele.textContent,
          set: v => {
            $ele.textContent = v
          }
        })
      }
    })
  }

  #listenForActions() {
    Object.entries(this.actions).forEach(([type, actions]) => {
      // Warn if the action type is unknown. See `actionEvents`.
      if (!actionEvents.has(type)) {
        console.warn(
          '%c[WebComponent]%c Unknown action: %o for %o',
          'font-weight: bold',
          'font-weight: normal',
          type,
          this.constructor.componentName
        )
        return
      }

      // Type is defined, but no actions are given, so ignore.
      if (actions.length === 0) return

      this.#hasActions.add(type)
      this.addEventListener(type, this.#handleAction)
    })
  }

  #unlistenForActions() {
    this.#hasActions.forEach(type => {
      this.removeEventListener(type, this.#handleAction)
    })
  }

  #handleAction = event => {
    if (!Object.keys(this.actions).includes(event.type)) return

    const actionAttr = `on-${event.type}`
    const target = event.target.closest(`[${actionAttr}]`)

    if (!target) return

    const action = target.getAttribute(actionAttr)

    if (this.actions[event.type].includes(action)) {
      if (this[action] === undefined) {
        throw new TypeError(
          `Function for action '${action}' is not defined in ${this.constructor.name}`
        )
      }

      this[action](event, target)
    }
  }

  #buildEventListenerArguments(eventName, callback, options) {
    if (callback === undefined) {
      callback = this
    } else if (isPlainObject(callback)) {
      options = callback
      callback = this
    }

    if (eventName.startsWith(':')) {
      eventName = this.constructor.componentName + eventName
    }

    return [eventName, callback, options]
  }
}

// Proxy the prototype to lazily resolve $<name>Target and $<name>Targets properties from the DOM.
Object.setPrototypeOf(
  WebComponent.prototype,
  new Proxy(Object.getPrototypeOf(WebComponent.prototype), {
    get(target, prop, receiver) {
      if (typeof prop === 'string' && !Object.hasOwn(receiver, prop)) {
        let match
        if ((match = prop.match(/^\$(.+)Targets$/))) {
          return receiver.$$(`[data-target="${match[1]}"]`)
        }
        if ((match = prop.match(/^\$(.+)Target$/))) {
          return receiver.$(`[data-target="${match[1]}"]`)
        }
      }
      return Reflect.get(target, prop, receiver)
    }
  })
)

function isPlainObject(value) {
  if (Object.prototype.toString.call(value) !== '[object Object]') return false

  const prototype = Object.getPrototypeOf(value)
  return prototype === null || prototype === Object.prototype
}

export function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

export function camelCase(str) {
  return str.replace(/-([a-z])/g, (_, char) => char.toUpperCase())
}

export default WebComponent
