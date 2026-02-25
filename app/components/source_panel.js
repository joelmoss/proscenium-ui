document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[role="tab"]').forEach(tab => {
    tab.addEventListener('click', () => {
      const panel = tab.closest('[role="tablist"]').parentElement
      const index = tab.dataset.tab

      panel.querySelectorAll('[role="tab"]').forEach(t => {
        t.setAttribute('aria-selected', t.dataset.tab === index)
      })

      panel.querySelectorAll('[role="tabpanel"]').forEach(p => {
        p.hidden = p.dataset.panel !== index
      })
    })
  })
})
