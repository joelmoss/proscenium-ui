# frozen_string_literal: true

module Views
  class DropdownMenu::Basic < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'DropdownMenu'

    def view_template
      cls = Class.new Proscenium::UI::DropdownMenu do
        def trigger_template
          super { 'Account' }
        end

        def menu_template
          item(href: '#') { 'Profile' }
          item(href: '#') { 'Settings' }
          item { 'Invite teammates' }
          hr
          item(disabled: true) { 'Billing (coming soon)' }
          item(href: '#') { 'Sign out' }
        end
      end

      render cls.new
    end
  end
end
