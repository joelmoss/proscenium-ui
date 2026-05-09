# frozen_string_literal: true

module Views
  class Test::WebComponent::Actions < Application
    include Phlexible::Rails::AutoLayout

    sideload_assets js: { type: 'module' }

    register_element :pui_test_actions

    self.page_title = 'WebComponent — actions'

    def view_template
      h1 { 'Actions' }

      pui_test_actions(id: 'actions-host') do
        button(id: 'click-btn', 'on-click': 'doClick') { 'click' }
        input(id: 'change-input', type: 'text', 'on-change': 'doChange')
        input(id: 'key-input', type: 'text', 'on-keydown': 'doKey')
        div(id: 'click-target', 'on-click': 'doClick') do
          span(id: 'click-target-inner') { 'inner' }
        end
        ul(id: 'action-log')
      end
    end
  end
end
