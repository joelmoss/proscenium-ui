# frozen_string_literal: true

module Proscenium::UI::Form::Fields
  class Combobox < Base
    register_element :pui_combobox_field

    def initialize(attribute, model, form, type: nil, error: nil, **attributes)
      super

      @options_from_attributes = @attributes.delete(:options)
      @src = @attributes.delete(:src)
      @multiple = @attributes.delete(:multiple) || false
      @placeholder = @attributes.delete(:placeholder)
      @min_chars = @attributes.delete(:min_chars) || 0
      @debounce_ms = @attributes.delete(:debounce) || 300
      @disabled = @attributes.delete(:disabled) || false
      @selected_options = @attributes.delete(:selected_options) || []
    end

    def view_template
      field :pui_combobox_field do
        label { |content| content }
        render Proscenium::UI::Combobox.new(
          name: resolved_field_name,
          options: resolved_options,
          src: @src,
          multiple: @multiple,
          placeholder: @placeholder,
          value: resolved_value,
          min_chars: @min_chars,
          debounce: @debounce_ms,
          disabled: @disabled,
          selected_options: @selected_options
        )
        render_hint
      end
    end

    private

      def render_hint
        content = attributes.delete(:hint)
        return if content == false

        content ||= translate(:hints)
        content.present? && div(part: :hint) { plain content }
      end

      def resolved_field_name
        if @multiple
          field_name(multiple: true)
        else
          field_name
        end
      end

      def resolved_value
        val = value
        case val
        when Array then val.map(&:to_s)
        when nil then nil
        else val.to_s
        end
      end

      def resolved_options
        if @options_from_attributes
          @options_from_attributes
        elsif enum_attribute?
          fetch_enum_collection.map do |opt|
            [model_class.human_attribute_name("#{attribute.last}.#{opt}"), opt]
          end
        elsif association_attribute?
          fetch_association_collection.map do |opt|
            [opt.to_s, opt.id.to_s]
          end
        else
          []
        end
      end

      def enum_attribute?
        model_class.defined_enums.key?(attribute.last.to_s)
      end

      def association_attribute?
        association_reflection.present?
      end

      def association_reflection
        @association_reflection ||= model_class.try(:reflect_on_association, attribute.last)
      end

      def fetch_enum_collection
        actual_model.defined_enums[attribute.last.to_s].keys
      end

      def fetch_association_collection
        reflection = association_reflection
        relation = reflection.klass.all

        if reflection.respond_to?(:scope) && reflection.scope
          relation = if reflection.scope.parameters.any?
                       reflection.klass.instance_exec(actual_model, &reflection.scope)
                     else
                       reflection.klass.instance_exec(&reflection.scope)
                     end
        end

        relation
      end

      def model_class
        @model_class ||= actual_model.class
      end
  end
end
