# frozen_string_literal: true

module Views
  class Test::WebComponent::Events < Application
    include Phlexible::Rails::AutoLayout

    sideload_assets js: { type: 'module' }

    register_element :pui_test_events
    register_element :pui_test_listener

    self.page_title = 'WebComponent — events'

    def view_template
      h1 { 'listen / dispatch / handleEvent' }

      pui_test_events(id: 'events-host') do
        button(id: 'self-btn', 'on-click': 'fireSelf') { 'self' }
        button(id: 'doc-btn', 'on-click': 'fireDoc') { 'doc' }
        button(id: 'caret-btn', 'on-click': 'fireCaret') { 'caret' }
        button(id: 'handle-btn', 'on-click': 'fireHandle') { 'handle' }
        button(id: 'handle-ns-btn', 'on-click': 'fireHandleNs') { 'handle-ns' }
        button(id: 'opts-btn', 'on-click': 'fireOpts') { 'opts' }
        button(id: 'unlisten-btn', 'on-click': 'unsubscribe') { 'unlisten' }
        button(id: 'dispatch-self-btn', 'on-click': 'dispatchSelf') { 'd-self' }
        button(id: 'dispatch-already-ns-btn', 'on-click': 'dispatchAlreadyNs') { 'd-already-ns' }
        button(id: 'dispatch-plain-btn', 'on-click': 'dispatchPlain') { 'd-plain' }
        ul(id: 'events-log')
      end

      pui_test_listener(id: 'listener-host')
    end
  end
end
