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

    # `view_template` is the host element, wrapping the whole dropdown. Each registered element
    # below is rendered by its own `*_template` method, which emits the element with its default
    # attributes and yields its content. Override one in a subclass and call `super`, passing
    # attributes to adjust the element and/or a block to fill it:
    #
    #   def view_template     = super(class: :@menu)             # add a class to the host
    #   def trigger_template  = super { img(src: avatar) }       # fill the trigger
    #   def body_template     = super(class: :@body) { ul { } }  # adjust and fill the body
    #
    # `body_template` is the floating panel. The trigger and body are empty until a subclass fills
    # them.
    def view_template(**attributes)
      send(host_element, **attributes) do
        trigger_template
        container_template do
          body_template
          arrow_template
        end
      end
    end

    private

      def trigger_template(**attributes, &)
        pui_dropdown_trigger(
          tabindex: 0,
          role: 'button',
          aria_haspopup: 'true',
          aria_expanded: 'false',
          aria_controls: container_id,
          on_click: :toggle,
          on_keydown: :onTriggerKey,
          **attributes,
          &
        )
      end

      def container_template(**attributes, &)
        pui_dropdown_container(id: container_id, popover: :auto, **attributes, &)
      end

      def body_template(**attributes, &) = pui_dropdown_body(**attributes, &)
      def arrow_template(**attributes) = pui_dropdown_arrow(**attributes)

      def container_id = @container_id ||= "pui-dd-#{object_id}"
      def host_element = :pui_dropdown
  end
end
