document.addEventListener('DOMContentLoaded', () => {
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

  document.querySelectorAll('[data-color-scheme-btn]').forEach(btn => {
    btn.addEventListener('click', () => {
      const scheme = btn.dataset.colorSchemeBtn
      document.querySelectorAll('[data-color-scheme-btn]').forEach(b => {
        b.setAttribute('aria-pressed', b.dataset.colorSchemeBtn === scheme)
      })

      const iframe = document.querySelector('iframe')
      if (iframe?.contentDocument) {
        iframe.contentDocument.documentElement.dataset.colorScheme = scheme
      }

      const url = new URL(window.location)
      url.searchParams.set('color_scheme', scheme)
      fetch(url, { method: 'HEAD' })
    })
  })
})
