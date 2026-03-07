# frozen_string_literal: true

module Proscenium::UI
  class Badge < Component
    register_element :pui_badge

    # @param text [String] The text content of the badge.
    prop :text, String, :positional

    # @param variant [Symbol] The visual style variant. (:default, :success, :warning, :danger,
    # :info)
    prop :variant, _Union(:default, :success, :warning, :danger, :info), default: -> { :default }

    # @param size [Symbol] The size of the badge. (:sm, :md, :lg)
    prop :size, _Union(:sm, :md, :lg), default: -> { :md }

    # @param rest [Hash] Additional HTML attributes passed to the root element.
    prop :rest, Hash, :**

    def self.source_path
      super.sub_ext('').join('index.rb')
    end

    def view_template
      data = {}
      data[:variant] = @variant if @variant != :default
      data[:size] = @size if @size != :md

      pui_badge(**{ data: }.deep_merge(@rest)) { @text }
    end
  end
end
