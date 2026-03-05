# frozen_string_literal: true

module Proscenium::UI
  class Combobox < Component
    register_element :pui_combobox

    prop :options, _Array(_Any), default: -> { [] }
    prop :src, _Nilable(String)
    prop :multiple, _Boolean, default: -> { false }
    prop :placeholder, _Nilable(String)
    prop :name, _Nilable(String)
    prop :value, _Union(String, _Array(String), NilClass), default: -> {}
    prop :min_chars, Integer, default: -> { 0 }
    prop :debounce, Integer, default: -> { 300 }
    prop :disabled, _Boolean, default: -> { false }
    prop :selected_options, _Array(_Any), default: -> { [] }

    def self.source_path
      super.sub_ext('').join('index.rb')
    end

    def view_template
      @uid = "pui-cb-#{object_id}"

      data = {}
      data[:multiple] = '' if @multiple
      data[:src] = @src if @src
      data[:min_chars] = @min_chars if @min_chars.positive?
      data[:debounce] = @debounce if @debounce != 300

      pui_combobox(data:, **(@disabled ? { disabled: '' } : {})) do
        hidden_inputs
        tags_container if @multiple
        combobox_input
        listbox
      end
    end

    private

      def hidden_inputs
        if @multiple
          input(type: :hidden, name: @name, value: '')
          current_values.each do |val|
            input(type: :hidden, name: "#{@name}[]", value: val)
          end
        else
          input(type: :hidden, name: @name, value: current_single_value)
        end
      end

      def tags_container
        div(part: :tags) do
          selected_items.each do |item|
            span(part: :tag, data: { value: item[:value] }) do
              plain item[:label]
              whitespace
              button(part: 'tag-remove', type: :button,
                     aria_label: "Remove #{item[:label]}") { plain "\u00D7" }
            end
          end
        end
      end

      def combobox_input
        input(
          type: :text,
          role: :combobox,
          part: :input,
          autocomplete: :off,
          aria_autocomplete: :list,
          aria_expanded: 'false',
          aria_controls: "#{@uid}-listbox",
          placeholder: @placeholder,
          value: initial_input_value,
          **(@disabled ? { disabled: true } : {})
        )
      end

      def listbox
        ul(role: :listbox, part: :listbox, id: "#{@uid}-listbox", hidden: true) do
          normalized_options.each_with_index do |opt, i|
            li(
              role: :option,
              id: "#{@uid}-option-#{i}",
              data: { value: opt[:value] },
              aria_selected: option_selected?(opt[:value]) ? 'true' : nil
            ) { opt[:label] }
          end
        end
      end

      def initial_input_value
        return if @multiple

        selected = normalized_options.find { |opt| option_selected?(opt[:value]) }
        selected&.fetch(:label)
      end

      def normalized_options
        @normalized_options ||= @options.map do |opt|
          case opt
          when String
            { label: opt, value: opt }
          when Array
            { label: opt[0], value: opt[1].to_s }
          when Hash
            { label: opt[:label], value: opt[:value].to_s }
          end
        end
      end

      def current_values
        case @value
        when Array then @value
        when String then [@value]
        else []
        end
      end

      def current_single_value
        case @value
        when String then @value
        else ''
        end
      end

      def option_selected?(val)
        current_values.include?(val.to_s)
      end

      def selected_items
        if @selected_options.any?
          @selected_options.filter_map do |opt|
            case opt
            when Hash then { label: opt[:label], value: opt[:value].to_s }
            end
          end
        else
          normalized_options.select { |opt| option_selected?(opt[:value]) }
        end
      end
  end
end
