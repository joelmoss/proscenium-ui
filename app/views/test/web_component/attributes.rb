# frozen_string_literal: true

module Views
  class Test::WebComponent::Attributes < Application
    include Phlexible::Rails::AutoLayout

    sideload_assets js: { type: 'module' }

    register_element :pui_test_attrs
    register_element :pui_test_mixed

    self.page_title = 'WebComponent — attributes & registration'

    def view_template
      h1 { 'Observed attributes, mixins, and registration' }

      pui_test_attrs(id: 'attrs-host', data: { open: 'no' })

      pui_test_mixed(id: 'mixed-host', 'data-foo': 'a', 'data-bar': 'b')

      ul(id: 'static-log')
    end
  end
end
