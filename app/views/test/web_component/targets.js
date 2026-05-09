import WebComponent from '../../../../lib/proscenium/ui/web_component'

class TestTargets extends WebComponent {
  static componentName = 'pui-test-targets'
  static actions = {
    click: ['reportCounts', 'reportOverride', 'reportQueries']
  }

  #log(line) {
    const li = document.createElement('li')
    li.textContent = line
    this.querySelector('#targets-log').appendChild(li)
  }

  reportCounts() {
    const targets = this.$menuTargets
    this.#log(
      `menu:${targets.length}:${Array.isArray(targets)}:${this.$menuTarget?.id}:${this.$soleTarget?.id}`
    )
  }

  reportOverride() {
    // Override the target lookup with an explicit instance property — Proxy must yield to it.
    this.$menuTarget = { id: 'overridden' }
    this.#log(`override:${this.$menuTarget.id}`)
    delete this.$menuTarget
    this.#log(`restore:${this.$menuTarget.id}`)
  }

  reportQueries() {
    // $ and $$ helpers
    const single = this.$('#sole')
    const all = this.$$('[data-target="menu"]')
    this.#log(`q:${single?.id}:${all.length}:${Array.isArray(all)}`)
  }
}

WebComponent.register(TestTargets)
