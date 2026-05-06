# frozen_string_literal: true

module Proscenium::UI
  class Dropdown < Component
    register_element :pui_dropdown
    register_element :pui_dropdown_trigger
    register_element :pui_dropdown_container
    register_element :pui_dropdown_body
    register_element :pui_dropdown_arrow

    def self.source_path
      (super || superclass.source_path) / '../dropdown/index.rb'
    end

    def trigger_template
      raise NotImplementedError,
            "`#trigger_template` must be implemented in subclasses of #{self.class}"
    end

    def dropdown_template
      raise NotImplementedError,
            "`#dropdown_template` must be implemented in subclasses of #{self.class}"
    end

    def view_template = base_template

    private

      def base_template
        container_id = "pui-dd-#{object_id}"

        pui_dropdown do
          pui_dropdown_trigger(
            tabindex: 0,
            role: 'button',
            aria_haspopup: 'true',
            aria_expanded: 'false',
            aria_controls: container_id,
            on_click: :toggle,
            on_keydown: :onTriggerKey,
            &:trigger_template
          )

          pui_dropdown_container(id: container_id, popover: :auto) do
            pui_dropdown_body(&:dropdown_template)
            pui_dropdown_arrow
          end
        end
      end
  end
end
