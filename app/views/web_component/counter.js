import WebComponent from '/lib/proscenium/ui/web_component'

class Counter extends WebComponent {
  static componentName = 'pui-demo-counter'
  static actions = { click: ['increment', 'decrement', 'reset'] }

  increment() {
    this.countValue = String(Number(this.countValue) + 1)
  }

  decrement() {
    this.countValue = String(Number(this.countValue) - 1)
  }

  reset() {
    this.countValue = '0'
  }
}

WebComponent.register(Counter)
