# frozen_string_literal: true

module Proscenium::UI
  class DropdownMenu < Dropdown
    register_element :pui_dropdown_menu

    def self.source_path
      Pathname(__FILE__).sub_ext('').join('index.rb')
    end

    def menu_template
      raise NotImplementedError,
            "`#menu_template` must be implemented in subclasses of #{self.class}"
    end

    def dropdown_template
      menu_template
    end

    def item(href: nil, disabled: false, **attrs, &)
      base = { role: 'menuitem', tabindex: -1, **attrs }
      if disabled
        span(**base, aria_disabled: 'true', &)
      elsif href
        a(href: href, **base, &)
      else
        button(type: :button, **base, &)
      end
    end

    private

      def host_element = :pui_dropdown_menu
      def trigger_haspopup = 'menu'
      def container_role = 'menu'
  end
end
