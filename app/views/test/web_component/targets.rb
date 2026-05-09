# frozen_string_literal: true

module Views
  class Test::WebComponent::Targets < Application
    include Phlexible::Rails::AutoLayout

    sideload_assets js: { type: 'module' }

    register_element :pui_test_targets

    self.page_title = 'WebComponent — targets'

    def view_template
      h1 { 'Targets and selector helpers' }

      pui_test_targets(id: 'targets-host') do
        div(data: { target: 'menu' }, id: 't1') { 'first' }
        div(data: { target: 'menu' }, id: 't2') { 'second' }
        div(data: { target: 'sole' }, id: 'sole') { 'sole' }
        button(id: 'count-btn', 'on-click': 'reportCounts') { 'count' }
        button(id: 'override-btn', 'on-click': 'reportOverride') { 'override' }
        button(id: 'q-btn', 'on-click': 'reportQueries') { 'q' }
        ul(id: 'targets-log')
      end
    end
  end
end
