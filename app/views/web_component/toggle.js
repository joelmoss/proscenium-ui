import WebComponent from '/lib/proscenium/ui/web_component'

class Toggle extends WebComponent {
  static componentName = 'pui-demo-toggle'
  static observedAttributes = ['data-open']
  static actions = { click: ['toggle'] }

  // Click flips the attribute; observedAttributes drives the rest, so the click handler stays
  // declarative and small.
  toggle() {
    const next = this.dataset.open === 'true' ? 'false' : 'true'
    this.dataset.open = next
  }

  dataOpenChanged(_oldValue, newValue) {
    const isOpen = newValue === 'true'
    this.$panelTarget.hidden = !isOpen
    this.$('button').setAttribute('aria-expanded', String(isOpen))
    this.dispatch(':toggled', { detail: { open: isOpen } })
  }
}

WebComponent.register(Toggle)
