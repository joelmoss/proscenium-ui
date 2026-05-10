# frozen_string_literal: true

module Views
  class WebComponent::Counter < Application
    include Phlexible::Rails::AutoLayout

    sideload_assets js: { type: 'module' }

    register_element :pui_demo_counter

    self.page_title = 'WebComponent — counter example'

    def view_template
      pui_demo_counter do
        button(type: 'button', 'on-click': 'decrement', aria_label: 'decrement') { '−' }
        span(data: { value: 'count' }) { '0' }
        button(type: 'button', 'on-click': 'increment', aria_label: 'increment') { '+' }
        button(type: 'button', 'on-click': 'reset') { 'reset' }
      end
    end
  end
end
