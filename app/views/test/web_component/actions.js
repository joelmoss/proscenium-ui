import WebComponent from '../../../../lib/proscenium/ui/web_component'

class TestActions extends WebComponent {
  static componentName = 'pui-test-actions'
  static actions = {
    click: ['doClick'],
    change: ['doChange'],
    keydown: ['doKey']
  }

  #log(line) {
    const li = document.createElement('li')
    li.textContent = line
    this.querySelector('#action-log').appendChild(li)
  }

  doClick(event, target) {
    this.#log(`click:${target.id}:${event.target.id}`)
  }

  doChange(event, target) {
    this.#log(`change:${target.id}:${target.value}`)
  }

  doKey(event, target) {
    this.#log(`keydown:${target.id}:${event.key}`)
  }
}

WebComponent.register(TestActions)
