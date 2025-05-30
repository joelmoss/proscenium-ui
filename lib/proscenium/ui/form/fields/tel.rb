# frozen_string_literal: true

require 'phonelib'
require 'countries/iso3166'

module Proscenium::UI::Form::Fields
  class Tel < Base
    DEFAULT_COUNTRY = 'US'

    sideload_assets js: { type: 'module' }

    register_element :pui_tel_field

    def initialize(attribute, model, form, type: nil, error: nil, **attributes)
      super

      @default_country = @attributes.delete(:default_country)&.to_s&.upcase || DEFAULT_COUNTRY
    end

    def view_template
      field :pui_tel_field do
        label for: field_id

        div part: :inputs do
          div part: :country do
            select do
              countries.each do |name, code|
                option(value: code, selected: code == country) { name }
              end
            end
          end

          input(name: field_name, type: 'text', part: :number, id: field_id, **build_attributes)
        end

        hint
      end
    end

    private

      def country
        @country ||= if value.blank?
                       @default_country
                     else
                       Phonelib.parse(value, @default_country).country || @default_country
                     end
      end

      def countries
        ISO3166::Country.all_names_with_codes.to_h
      end
  end
end
