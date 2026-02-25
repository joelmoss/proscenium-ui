document.addEventListener('DOMContentLoaded', () => {
  const resizer = document.querySelector('[data-resizer]')
  if (resizer) {
    const panel = resizer.nextElementSibling
    let startY, startHeight

    resizer.addEventListener('mousedown', e => {
      startY = e.clientY
      startHeight = panel.offsetHeight
      document.body.style.cursor = 'row-resize'
      document.body.style.userSelect = 'none'

      const iframe = document.querySelector('iframe')
      if (iframe) iframe.style.pointerEvents = 'none'

      const onMouseMove = e => {
        const newHeight = Math.max(50, startHeight - (e.clientY - startY))
        panel.style.height = `${newHeight}px`
      }

      const onMouseUp = () => {
        document.removeEventListener('mousemove', onMouseMove)
        document.removeEventListener('mouseup', onMouseUp)
        document.body.style.cursor = ''
        document.body.style.userSelect = ''
        if (iframe) iframe.style.pointerEvents = ''
      }

      document.addEventListener('mousemove', onMouseMove)
      document.addEventListener('mouseup', onMouseUp)
    })
  }

  document.querySelectorAll('[data-viewport-btn]').forEach(btn => {
    btn.addEventListener('click', () => {
      const viewport = btn.dataset.viewportBtn
      document.querySelector('main').dataset.viewport = viewport
      document.querySelectorAll('[data-viewport-btn]').forEach(b => {
        b.setAttribute('aria-pressed', b.dataset.viewportBtn === viewport)
      })

      const url = new URL(window.location)
      url.searchParams.set('viewport', viewport)
      fetch(url, { method: 'HEAD' })
    })
  })

  // Clicking anywhere on summary navigates to the controller landing page
  document.querySelectorAll('details[data-nav-group] > summary').forEach(summary => {
    summary.addEventListener('click', e => {
      e.preventDefault()
      const path = summary.closest('[data-nav-group]').dataset.navGroup
      if (path) window.location = path
    })
  })

  const colorToggle = document.querySelector('[data-color-scheme-toggle]')
  if (colorToggle) {
    colorToggle.addEventListener('click', () => {
      const current = colorToggle.dataset.colorSchemeToggle
      const scheme = current === 'light' ? 'dark' : 'light'
      colorToggle.dataset.colorSchemeToggle = scheme

      colorToggle.querySelector('[data-icon="light"]').hidden = scheme !== 'dark'
      colorToggle.querySelector('[data-icon="dark"]').hidden = scheme !== 'light'

      const iframe = document.querySelector('iframe')
      if (iframe?.contentDocument) {
        iframe.contentDocument.documentElement.dataset.colorScheme = scheme
      }

      const url = new URL(window.location)
      url.searchParams.set('color_scheme', scheme)
      fetch(url, { method: 'HEAD' })
    })
  }
})
