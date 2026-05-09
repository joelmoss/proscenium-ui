# frozen_string_literal: true

module Views
  class Test::WebComponent::Values < Application
    include Phlexible::Rails::AutoLayout

    sideload_assets js: { type: 'module' }

    register_element :pui_test_values

    self.page_title = 'WebComponent — values'

    def view_template
      h1 { 'Reactive values' }

      pui_test_values(id: 'values-host') do
        span(id: 'count-display', data: { value: 'count' }) { '0' }
        span(id: 'name-display', data: { value: 'name' }) { 'world' }
        button(id: 'inc-btn', 'on-click': 'increment') { 'inc' }
        button(id: 'read-btn', 'on-click': 'readValues') { 'read' }
        ul(id: 'values-log')
      end
    end
  end
end
