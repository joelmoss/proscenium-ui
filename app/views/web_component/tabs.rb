# frozen_string_literal: true

module Views
  class WebComponent::Tabs < Application
    include Phlexible::Rails::AutoLayout

    sideload_assets js: { type: 'module' }

    register_element :pui_demo_tabs

    self.page_title = 'WebComponent — tabs example'

    TABS = [
      { id: 'overview', label: 'Overview', body: 'Project overview goes here.' },
      { id: 'details', label: 'Details', body: 'Implementation details go here.' },
      { id: 'changelog', label: 'Changelog', body: 'Release notes go here.' }
    ].freeze

    def view_template
      pui_demo_tabs do
        div(role: 'tablist') do
          TABS.each_with_index do |tab, i|
            button(
              type: 'button',
              role: 'tab',
              data: { target: 'tab', id: tab[:id] },
              aria_selected: i.zero?.to_s,
              tabindex: i.zero? ? 0 : -1,
              'on-click': 'select',
              'on-keydown': 'onKey'
            ) { tab[:label] }
          end
        end

        TABS.each_with_index do |tab, i|
          div(
            role: 'tabpanel',
            data: { target: 'panel', id: tab[:id] },
            hidden: !i.zero? || nil
          ) { p { tab[:body] } }
        end
      end
    end
  end
end
