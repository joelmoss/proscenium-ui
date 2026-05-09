import WebComponent from '../web_component'
import { Dropdown } from '../dropdown/index.js'

const TYPEAHEAD_TIMEOUT = 500

class DropdownMenu extends Dropdown {
  static componentName = 'pui-dropdown-menu'

  #typeBuffer = ''
  #typeTimer = null

  connectedCallback() {
    super.connectedCallback()
    this.$container?.addEventListener('keydown', this.#onMenuKey)
    this.$container?.addEventListener('click', this.#onMenuClick)
  }

  disconnectedCallback() {
    super.disconnectedCallback()
    this.$container?.removeEventListener('keydown', this.#onMenuKey)
    this.$container?.removeEventListener('click', this.#onMenuClick)
  }

  open() {
    if (this.isOpen) return
    super.open()
    queueMicrotask(() => {
      const items = this.#items()
      if (items.length > 0) items[0].focus()
    })
  }

  #onMenuKey = event => {
    const items = this.#items()
    if (items.length === 0) return

    const current = items.indexOf(document.activeElement)

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.#focusAt(items, current + 1)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.#focusAt(items, current - 1)
        break
      case 'Home':
        event.preventDefault()
        this.#focusAt(items, 0)
        break
      case 'End':
        event.preventDefault()
        this.#focusAt(items, items.length - 1)
        break
      case 'Tab':
        this.close()
        break
      default:
        if (event.key.length === 1 && /\S/.test(event.key)) {
          this.#typeahead(event.key.toLowerCase(), items)
        }
    }
  }

  #onMenuClick = event => {
    const item = event.target.closest('[role="menuitem"]')
    if (!item || item.getAttribute('aria-disabled') === 'true') return
    this.close()
  }

  #focusAt(items, index) {
    const wrapped = ((index % items.length) + items.length) % items.length
    items[wrapped].focus()
  }

  #items() {
    return Array.from(
      this.$container.querySelectorAll('[role="menuitem"]:not([aria-disabled="true"])')
    )
  }

  #typeahead(char, items) {
    clearTimeout(this.#typeTimer)
    this.#typeBuffer += char
    this.#typeTimer = setTimeout(() => {
      this.#typeBuffer = ''
    }, TYPEAHEAD_TIMEOUT)

    const buffer = this.#typeBuffer
    const match = items.find(item => item.textContent.trim().toLowerCase().startsWith(buffer))
    if (match) match.focus()
  }
}

WebComponent.register(DropdownMenu)
