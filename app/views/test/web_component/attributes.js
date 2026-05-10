import WebComponent from '../../../../lib/proscenium/ui/web_component'

// Each mixin contributes a different observed attribute. withMixins must merge them.
function FooMixin(superClass) {
  return class extends superClass {
    static observedAttributes = ['data-foo']
  }
}

function BarMixin(superClass) {
  return class extends superClass {
    static observedAttributes = ['data-bar']
  }
}

class TestAttrs extends WebComponent {
  static componentName = 'pui-test-attrs'
  static observedAttributes = ['data-open']

  attrLog = []

  // attributeChangedCallback should route 'data-open' → camelCase → 'dataOpenChanged'.
  dataOpenChanged(oldValue, newValue) {
    this.attrLog.push(`data-open:${oldValue}->${newValue}`)
  }
}

class TestMixed extends WebComponent.withMixins(FooMixin, BarMixin) {
  static componentName = 'pui-test-mixed'

  attrLog = []

  dataFooChanged(oldValue, newValue) {
    this.attrLog.push(`data-foo:${oldValue}->${newValue}`)
  }

  dataBarChanged(oldValue, newValue) {
    this.attrLog.push(`data-bar:${oldValue}->${newValue}`)
  }
}

// 1. register() throws TypeError when componentName is missing.
function recordRegistrationError() {
  const ul = document.querySelector('#static-log')
  if (!ul) {
    queueMicrotask(recordRegistrationError)
    return
  }

  const log = (label, value) => {
    const li = document.createElement('li')
    li.dataset.label = label
    li.textContent = `${label}:${value}`
    ul.appendChild(li)
  }

  try {
    class NoName extends WebComponent {}
    WebComponent.register(NoName)
    log('no-name', 'no-throw')
  } catch (e) {
    log('no-name', `${e.name}:${e.message}`)
  }

  // 2. register() is idempotent — second call is a no-op.
  try {
    WebComponent.register(TestAttrs)
    WebComponent.register(TestAttrs)
    log('idempotent', 'ok')
  } catch (e) {
    log('idempotent', `${e.name}:${e.message}`)
  }

  // 3. observedAttributes merges from mixin contributions (set up by withMixins).
  const mixedAttrs = TestMixed.observedAttributes ?? []
  log('mixed-observes', `${mixedAttrs.includes('data-foo')}:${mixedAttrs.includes('data-bar')}`)

  // 4. observedAttributes from a subclass merges with the parent's at register time.
  class WithExtraObserved extends TestAttrs {
    static componentName = 'pui-test-extra'
    static observedAttributes = ['data-extra']
  }
  WebComponent.register(WithExtraObserved)
  const merged = WithExtraObserved.observedAttributes
  log('merged-observes', `${merged.includes('data-extra')}:${merged.includes('data-open')}`)

  // 5. The four drag-and-drop action types are recognised — registering them must not
  //    emit the "Unknown action" warning that #listenForActions logs for unknown types.
  class DragProbe extends WebComponent {
    static componentName = 'pui-test-drag-probe'
    static actions = {
      dragstart: ['noop'],
      dragover: ['noop'],
      drop: ['noop'],
      dragend: ['noop']
    }
    noop() {}
  }
  WebComponent.register(DragProbe)

  const warnings = []
  const origWarn = console.warn
  console.warn = (...args) => {
    warnings.push(args.join(' '))
    origWarn.apply(console, args)
  }
  document.body.appendChild(document.createElement('pui-test-drag-probe'))
  console.warn = origWarn

  const unknown = warnings.some(w => w.includes('Unknown action'))
  log('drag-actions', unknown ? 'unknown-action-warning' : 'ok')
}

WebComponent.register(TestAttrs)
WebComponent.register(TestMixed)
recordRegistrationError()
