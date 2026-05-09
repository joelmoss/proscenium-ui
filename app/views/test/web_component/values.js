import WebComponent from '../../../../lib/proscenium/ui/web_component'

class TestValues extends WebComponent {
  static componentName = 'pui-test-values'
  static actions = {
    click: ['increment', 'readValues']
  }

  #log(line) {
    const li = document.createElement('li')
    li.textContent = line
    this.querySelector('#values-log').appendChild(li)
  }

  increment() {
    // Setting the property must update the element's textContent.
    const next = Number(this.countValue) + 1
    this.countValue = String(next)
  }

  readValues() {
    this.#log(`read:${this.countValue}:${this.nameValue}`)
  }
}

WebComponent.register(TestValues)
