import WebComponent from '../web_component'

const SUPPORTS_POPOVER =
  typeof HTMLElement !== 'undefined' && typeof HTMLElement.prototype.showPopover === 'function'

WebComponent.register(
  class extends WebComponent {
    static componentName = 'pui-dropdown'
    static actions = { click: ['toggle'], keydown: ['onTriggerKey'] }

    #originalParent = null
    #originalNextSibling = null
    #cleanupPosition = null

    connectedCallback() {
      super.connectedCallback()

      this.fui = import('@floating-ui/dom')
      this.$container?.addEventListener('toggle', this.#onToggle)
    }

    disconnectedCallback() {
      super.disconnectedCallback()

      if (this.$container?.parentNode === document.body) {
        this.$container.remove()
      }

      this.$container?.removeEventListener('toggle', this.#onToggle)
      this.#removeListeners()
    }

    handleEvent(event) {
      if (event.type === 'blur' && event.target === globalThis) {
        this.close()
      }
    }

    toggle = () => {
      this.isOpen ? this.close() : this.open()
    }

    onTriggerKey = event => {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault()
        this.toggle()
      }
    }

    #onToggle = event => {
      if (event.newState !== 'closed' || !this.isOpen) return

      this.close()

      const ae = document.activeElement
      if (ae === document.body || this.contains(ae)) {
        this.$trigger.focus()
      }
    }

    open() {
      if (this.isOpen) return

      this.#showContainer()
      this.dataset.open = true
      this.$container.dataset.open = true
      this.$trigger.setAttribute('aria-expanded', 'true')
      this.#startPositionUpdates()
      this.#addListeners()
    }

    close = () => {
      if (!this.isOpen) return

      delete this.dataset.open
      delete this.$container.dataset.open
      this.$trigger.setAttribute('aria-expanded', 'false')

      this.#cleanupPosition?.()
      this.#cleanupPosition = null

      this.#hideContainer()
      this.#removeListeners()
    }

    get isOpen() {
      return 'open' in this.dataset
    }

    #showContainer() {
      if (SUPPORTS_POPOVER) {
        this.$container.showPopover()
      } else {
        this.#originalParent = this.$container.parentNode
        this.#originalNextSibling = this.$container.nextSibling
        document.body.append(this.$container)
      }
    }

    #hideContainer() {
      if (SUPPORTS_POPOVER) {
        this.$container.hidePopover()
      } else if (this.#originalParent) {
        this.#originalParent.insertBefore(this.$container, this.#originalNextSibling)
        this.#originalParent = null
        this.#originalNextSibling = null
      }
    }

    #addListeners() {
      window.addEventListener('blur', this, { once: true })
    }

    #removeListeners() {
      window.removeEventListener('blur', this, { once: true })
    }

    async #startPositionUpdates() {
      const { computePosition, offset, flip, shift, arrow, autoUpdate } = await this.fui

      const update = () => {
        computePosition(this.$trigger, this.$container, {
          strategy: 'fixed',
          placement: 'bottom-start',
          middleware: [offset(6), flip(), shift({ padding: 5 }), arrow({ element: this.$arrow })]
        }).then(({ x, y, placement, middlewareData }) => {
          Object.assign(this.$container.style, {
            left: `${x}px`,
            top: `${y}px`
          })

          const { x: arrowX, y: arrowY } = middlewareData.arrow
          const side = placement.split('-')[0]
          const staticSide = { top: 'bottom', right: 'left', bottom: 'top', left: 'right' }[side]
          const outerBorders = {
            bottom: ['borderLeft', 'borderTop'],
            top: ['borderRight', 'borderBottom'],
            right: ['borderLeft', 'borderBottom'],
            left: ['borderTop', 'borderRight']
          }[side]
          const border =
            '1px solid var(--pui-dropdown-border-color, color-mix(in srgb, CanvasText 20%, transparent))'

          Object.assign(this.$arrow.style, {
            left: arrowX == null ? '' : `${arrowX}px`,
            top: arrowY == null ? '' : `${arrowY}px`,
            right: '',
            bottom: '',
            borderTop: '',
            borderRight: '',
            borderBottom: '',
            borderLeft: '',
            [staticSide]: '-4px',
            [outerBorders[0]]: border,
            [outerBorders[1]]: border
          })
        })
      }

      const cleanup = autoUpdate(this.$trigger, this.$container, update)

      if (this.isOpen) {
        this.#cleanupPosition = cleanup
      } else {
        cleanup()
      }
    }

    get $trigger() {
      return (this._$trigger ??= this.querySelector('pui-dropdown-trigger'))
    }

    get $container() {
      return (this._$container ??= this.querySelector('pui-dropdown-container'))
    }

    get $arrow() {
      return (this._$arrow ??= this.$container.querySelector('pui-dropdown-arrow'))
    }
  }
)
