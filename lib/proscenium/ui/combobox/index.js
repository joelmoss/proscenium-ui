class PuiCombobox extends HTMLElement {
  connectedCallback() {
    this.$input = this.querySelector('[role="combobox"]')
    this.$listbox = this.querySelector('[role="listbox"]')
    this.$hidden = this.querySelector('input[type="hidden"]')
    this._uid = this.$listbox.id.replace('-listbox', '')
    this._activeIndex = -1
    this._abortController = null
    this._debounceTimer = null

    this.$input.addEventListener('input', this)
    this.$input.addEventListener('keydown', this)
    this.$input.addEventListener('focus', this)
    document.addEventListener('click', this)

    if (this.multiple) {
      this.querySelectorAll('[part="tag-remove"]').forEach(btn => {
        btn.addEventListener('click', this)
      })
    }
  }

  disconnectedCallback() {
    this.$input.removeEventListener('input', this)
    this.$input.removeEventListener('keydown', this)
    this.$input.removeEventListener('focus', this)
    document.removeEventListener('click', this)

    if (this._abortController) this._abortController.abort()
    if (this._debounceTimer) clearTimeout(this._debounceTimer)
  }

  handleEvent(event) {
    switch (event.type) {
      case 'input':
        this.#onInput(event)
        break
      case 'keydown':
        this.#onKeydown(event)
        break
      case 'focus':
        this.#onFocus()
        break
      case 'click':
        this.#onClick(event)
        break
    }
  }

  get multiple() {
    return this.hasAttribute('data-multiple')
  }

  get src() {
    return this.getAttribute('data-src')
  }

  get minChars() {
    return parseInt(this.getAttribute('data-min-chars') || '0', 10)
  }

  get debounce() {
    return parseInt(this.getAttribute('data-debounce') || '300', 10)
  }

  get options() {
    return Array.from(this.$listbox.querySelectorAll('[role="option"]'))
  }

  #onFocus() {
    if (!this.src && this.$input.value === '') {
      this.#showAll()
    }
  }

  #onInput() {
    const term = this.$input.value.trim()

    if (term.length < this.minChars) {
      this.#close()
      return
    }

    if (this.src) {
      this.#fetchAsync(term)
    } else {
      this.#filterStatic(term)
    }
  }

  #filterStatic(term) {
    const lower = term.toLowerCase()
    let hasVisible = false

    this.options.forEach(opt => {
      const match = opt.textContent.toLowerCase().includes(lower)
      opt.hidden = !match
      if (match) hasVisible = true
    })

    if (hasVisible) {
      this.#open()
    } else {
      this.#close()
    }

    this._activeIndex = -1
    this.#clearActive()
  }

  #fetchAsync(term) {
    if (this._debounceTimer) clearTimeout(this._debounceTimer)

    this._debounceTimer = setTimeout(async () => {
      if (this._abortController) this._abortController.abort()
      this._abortController = new AbortController()

      try {
        const url = new URL(this.src, window.location.origin)
        url.searchParams.set('q', term)

        const response = await fetch(url.toString(), {
          signal: this._abortController.signal,
          headers: { Accept: 'application/json' }
        })
        const data = await response.json()

        this.$listbox.innerHTML = ''
        data.forEach((item, i) => {
          const li = document.createElement('li')
          li.setAttribute('role', 'option')
          li.id = `${this._uid}-option-${i}`
          li.dataset.value = item.value
          li.textContent = item.label

          if (this.#isSelected(String(item.value))) {
            li.setAttribute('aria-selected', 'true')
          }

          this.$listbox.appendChild(li)
        })

        this._activeIndex = -1
        if (data.length > 0) {
          this.#open()
        } else {
          this.#close()
        }
      } catch (e) {
        if (e.name !== 'AbortError') throw e
      }
    }, this.debounce)
  }

  #onKeydown(event) {
    const opts = this.options.filter(o => !o.hidden)

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        if (!this.#isOpen()) {
          this.#showAll()
        } else {
          this._activeIndex = Math.min(this._activeIndex + 1, opts.length - 1)
          this.#setActive(opts)
        }
        break

      case 'ArrowUp':
        event.preventDefault()
        this._activeIndex = Math.max(this._activeIndex - 1, 0)
        this.#setActive(opts)
        break

      case 'Home':
        event.preventDefault()
        this._activeIndex = 0
        this.#setActive(opts)
        break

      case 'End':
        event.preventDefault()
        this._activeIndex = opts.length - 1
        this.#setActive(opts)
        break

      case 'Enter':
        event.preventDefault()
        if (this._activeIndex >= 0 && this._activeIndex < opts.length) {
          this.#selectOption(opts[this._activeIndex])
        }
        break

      case 'Escape':
        this.#close()
        this.$input.blur()
        break

      case 'Backspace':
        if (this.multiple && this.$input.value === '') {
          this.#removeLastTag()
        }
        break
    }
  }

  #onClick(event) {
    const option = event.target.closest('[role="option"]')
    if (option && this.$listbox.contains(option)) {
      this.#selectOption(option)
      return
    }

    const removeBtn = event.target.closest('[part="tag-remove"]')
    if (removeBtn && this.contains(removeBtn)) {
      const tag = removeBtn.closest("[part='tag']")
      if (tag) this.#removeTag(tag.dataset.value)
      return
    }

    if (!this.contains(event.target)) {
      this.#close()
    }
  }

  #selectOption(option) {
    const value = option.dataset.value
    const label = option.textContent

    if (this.multiple) {
      if (this.#isSelected(value)) {
        this.#removeTag(value)
      } else {
        this.#addTag(label, value)
        option.setAttribute('aria-selected', 'true')
      }
      this.$input.value = ''
      this.$input.focus()
    } else {
      this.$input.value = label
      this.$hidden.value = value

      this.options.forEach(o => o.removeAttribute('aria-selected'))
      option.setAttribute('aria-selected', 'true')

      this.#close()
    }

    this.dispatchEvent(
      new CustomEvent('combobox:change', {
        detail: { value: this.multiple ? this.#selectedValues() : value },
        bubbles: true
      })
    )
  }

  #addTag(label, value) {
    // Add hidden input
    const hiddenInput = document.createElement('input')
    hiddenInput.type = 'hidden'
    hiddenInput.name = this.$hidden.name + '[]'
    hiddenInput.value = value
    this.$hidden.after(hiddenInput)

    // Add tag element
    const tagsContainer = this.querySelector('[part="tags"]')
    const tag = document.createElement('span')
    tag.setAttribute('part', 'tag')
    tag.dataset.value = value
    tag.textContent = label + ' '

    const removeBtn = document.createElement('button')
    removeBtn.setAttribute('part', 'tag-remove')
    removeBtn.type = 'button'
    removeBtn.setAttribute('aria-label', `Remove ${label}`)
    removeBtn.innerHTML = '&times;'
    removeBtn.addEventListener('click', this)

    tag.appendChild(removeBtn)
    tagsContainer.appendChild(tag)
  }

  #removeTag(value) {
    // Remove hidden input
    const input = this.querySelector(
      `input[type="hidden"][value="${CSS.escape(value)}"][name$="[]"]`
    )
    if (input) input.remove()

    // Remove tag element
    const tag = this.querySelector(`[part="tag"][data-value="${CSS.escape(value)}"]`)
    if (tag) {
      const btn = tag.querySelector('[part="tag-remove"]')
      if (btn) btn.removeEventListener('click', this)
      tag.remove()
    }

    // Update listbox
    this.options.forEach(opt => {
      if (opt.dataset.value === value) {
        opt.removeAttribute('aria-selected')
      }
    })

    this.dispatchEvent(
      new CustomEvent('combobox:change', {
        detail: { value: this.#selectedValues() },
        bubbles: true
      })
    )
  }

  #removeLastTag() {
    const tags = this.querySelectorAll('[part="tag"]')
    if (tags.length > 0) {
      const lastTag = tags[tags.length - 1]
      this.#removeTag(lastTag.dataset.value)
    }
  }

  #isSelected(value) {
    return !!this.querySelector(`input[type="hidden"][value="${CSS.escape(value)}"][name$="[]"]`)
  }

  #selectedValues() {
    return Array.from(this.querySelectorAll('input[type="hidden"][name$="[]"]')).map(
      input => input.value
    )
  }

  #showAll() {
    this.options.forEach(opt => (opt.hidden = false))
    this.#open()
  }

  #open() {
    this.$listbox.hidden = false
    this.$input.setAttribute('aria-expanded', 'true')
  }

  #close() {
    this.$listbox.hidden = true
    this.$input.setAttribute('aria-expanded', 'false')
    this._activeIndex = -1
    this.#clearActive()
  }

  #isOpen() {
    return !this.$listbox.hidden
  }

  #setActive(opts) {
    this.#clearActive()
    if (this._activeIndex >= 0 && this._activeIndex < opts.length) {
      const opt = opts[this._activeIndex]
      opt.setAttribute('data-active', '')
      this.$input.setAttribute('aria-activedescendant', opt.id)
      opt.scrollIntoView({ block: 'nearest' })
    }
  }

  #clearActive() {
    this.options.forEach(o => o.removeAttribute('data-active'))
    this.$input.removeAttribute('aria-activedescendant')
  }
}

!customElements.get('pui-combobox') && customElements.define('pui-combobox', PuiCombobox)
