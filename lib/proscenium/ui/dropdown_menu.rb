# frozen_string_literal: true

module Proscenium::UI
  class DropdownMenu < Dropdown
    register_element :pui_dropdown_menu

    def self.source_path
      Pathname(__FILE__).sub_ext('').join('index.rb')
    end

    # DropdownMenu keeps a dedicated content hook for the menu body, so subclasses implement
    # `menu_template` (using `item`/`hr`) rather than filling `body_template` directly.
    def menu_template
      raise NotImplementedError,
            "`#menu_template` must be implemented in subclasses of #{self.class}"
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

      def trigger_template(**attributes, &) = super(aria_haspopup: 'menu', **attributes, &)
      def container_template(**attributes, &) = super(role: 'menu', **attributes, &)
      def body_template = super { menu_template }

      def host_element = :pui_dropdown_menu
  end
end
