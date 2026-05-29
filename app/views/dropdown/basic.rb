# frozen_string_literal: true

module Views
  class Dropdown::Basic < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Dropdown'

    def view_template
      cls = Class.new Proscenium::UI::Dropdown do
        def trigger_template
          super { 'Open' }
        end

        def body_template
          super do
            h4 { 'Hello, World!' }
            a(href: '#') { 'Click me!' }
          end
        end
      end

      render cls.new
    end
  end
end
