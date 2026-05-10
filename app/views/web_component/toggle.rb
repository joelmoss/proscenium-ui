# frozen_string_literal: true

module Views
  class WebComponent::Toggle < Application
    include Phlexible::Rails::AutoLayout

    sideload_assets js: { type: 'module' }

    register_element :pui_demo_toggle

    self.page_title = 'WebComponent — toggle example'

    def view_template
      pui_demo_toggle(data: { open: 'false' }) do
        button(type: 'button', 'on-click': 'toggle', aria_expanded: 'false') do
          'Show details'
        end
        div(data: { target: 'panel' }, hidden: true) do
          p do
            'Toggle the button to flip the data-open attribute. The component reacts via ' \
              'observedAttributes and toggles the panel\'s hidden state.'
          end
        end
      end
    end
  end
end
