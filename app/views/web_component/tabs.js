import WebComponent from '/lib/proscenium/ui/web_component'

class Tabs extends WebComponent {
  static componentName = 'pui-demo-tabs'
  static actions = { click: ['select'], keydown: ['onKey'] }

  // Click on a tab → activate it.
  select(_event, target) {
    this.#activate(target.dataset.id)
  }

  // Arrow keys move focus & selection between tabs.
  onKey(event, target) {
    const ids = this.$tabTargets.map(el => el.dataset.id)
    const i = ids.indexOf(target.dataset.id)

    if (event.key === 'ArrowRight') {
      event.preventDefault()
      this.#activate(ids[(i + 1) % ids.length], { focus: true })
    } else if (event.key === 'ArrowLeft') {
      event.preventDefault()
      this.#activate(ids[(i - 1 + ids.length) % ids.length], { focus: true })
    }
  }

  #activate(id, { focus = false } = {}) {
    this.$tabTargets.forEach(el => {
      const active = el.dataset.id === id
      el.setAttribute('aria-selected', String(active))
      el.tabIndex = active ? 0 : -1
      if (active && focus) el.focus()
    })

    this.$panelTargets.forEach(el => {
      el.hidden = el.dataset.id !== id
    })

    this.dispatch(':selected', { detail: { id } })
  }
}

WebComponent.register(Tabs)
