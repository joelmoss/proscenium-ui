import WebComponent from '../../../../lib/proscenium/ui/web_component'

// Listener subclass we can mutate for the cross-component dispatch test.
class TestListener extends WebComponent {
  static componentName = 'pui-test-listener'
}

class TestEvents extends WebComponent {
  static componentName = 'pui-test-events'
  static actions = {
    click: [
      'fireSelf',
      'fireDoc',
      'fireCaret',
      'fireHandle',
      'fireHandleNs',
      'fireOpts',
      'unsubscribe',
      'dispatchSelf',
      'dispatchAlreadyNs',
      'dispatchPlain'
    ]
  }

  #handleCount = 0

  #log(line) {
    const li = document.createElement('li')
    li.textContent = line
    this.querySelector('#events-log').appendChild(li)
  }

  // listen(':event', cb): name is resolved to `<componentName>:event`. Because the resolved name
  // contains ':', the listener attaches to `document`. Dispatching the same event on `this` with
  // bubbles: true reaches the document listener.
  fireSelf() {
    const cb = e => this.#log(`self:${e.type}:${e.detail?.from}`)
    this.listen(':ping', cb)
    this.dispatchEvent(
      new CustomEvent('pui-test-events:ping', { detail: { from: 'fireSelf' }, bubbles: true })
    )
    this.unlisten(':ping', cb)
  }

  // ':' anywhere in the name → listener attaches to document.
  fireDoc() {
    const cb = e => this.#log(`doc:${e.type}`)
    this.listen('other:event', cb)
    document.dispatchEvent(new CustomEvent('other:event'))
    this.unlisten('other:event', cb)
  }

  // '^' prefix → listener attaches to document, prefix stripped from type.
  fireCaret() {
    const cb = e => this.#log(`caret:${e.type}`)
    this.listen('^plain-doc-event', cb)
    document.dispatchEvent(new CustomEvent('plain-doc-event'))
    this.unlisten('^plain-doc-event', cb)
  }

  // No callback → listener is `this`; handleEvent routes plain 'ping' to onPing.
  fireHandle() {
    this.listen('ping')
    this.dispatchEvent(new CustomEvent('ping', { detail: { from: 'handle' } }))
    this.unlisten('ping')
  }

  // No callback + namespaced event → listener on document; handleEvent strips prefix → onPing.
  fireHandleNs() {
    this.listen(':ping')
    this.dispatchEvent(
      new CustomEvent('pui-test-events:ping', { detail: { from: 'handleNs' }, bubbles: true })
    )
    this.unlisten(':ping')
  }

  // 2nd arg is options object → callback defaults to `this`; once auto-removes after first call.
  fireOpts() {
    this.listen('ping', { once: true })
    this.dispatchEvent(new CustomEvent('ping', { detail: { from: 'opts1' } }))
    this.dispatchEvent(new CustomEvent('ping', { detail: { from: 'opts2' } }))
  }

  onPing(event) {
    this.#handleCount += 1
    this.#log(`onPing:${this.#handleCount}:${event.detail?.from}`)
  }

  // Unlisten removes the listener — second dispatch must not fire the callback.
  unsubscribe() {
    let count = 0
    const cb = () => {
      count += 1
    }
    this.listen('toggle', cb)
    this.dispatchEvent(new Event('toggle'))
    this.unlisten('toggle', cb)
    this.dispatchEvent(new Event('toggle'))
    this.#log(`unsub:${count}`)
  }

  // dispatch(':event') → resolved to '<componentName>:event' → fires on `this`. Bubbles.
  dispatchSelf() {
    let receivedOn = null
    const onSelf = e => {
      receivedOn = e.currentTarget.tagName.toLowerCase()
    }
    this.addEventListener('pui-test-events:custom', onSelf)
    const ev = this.dispatch(':custom', { detail: { x: 1 } })
    this.removeEventListener('pui-test-events:custom', onSelf)
    this.#log(`d-self:${ev.type}:${ev.detail?.x}:${ev.bubbles}:${receivedOn}`)
  }

  // dispatch with already-prefixed name matching componentName → fires on `this`.
  dispatchAlreadyNs() {
    let where = null
    const onSelf = () => {
      where = 'self'
    }
    this.addEventListener('pui-test-events:explicit', onSelf)
    this.dispatch('pui-test-events:explicit')
    this.removeEventListener('pui-test-events:explicit', onSelf)
    this.#log(`d-already-ns:${where}`)
  }

  // Plain event name → fires on document.
  dispatchPlain() {
    let where = null
    const cb = () => {
      where = 'doc'
    }
    document.addEventListener('plain-event', cb)
    this.dispatch('plain-event')
    document.removeEventListener('plain-event', cb)
    this.#log(`d-plain:${where}`)
  }
}

WebComponent.register(TestListener)
WebComponent.register(TestEvents)
