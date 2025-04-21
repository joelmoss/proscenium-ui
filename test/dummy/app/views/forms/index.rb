# frozen_string_literal: true

module Views
  class Forms::Index < Proscenium::Phlex
    def view_template
      render Proscenium::UI::Form.new User.new do |f|
        f.text_field :name
        f.textarea_field :address
        f.select_field :country, options: %w[USA Canada Mexico]
        f.checkbox_field :active?
        f.radio_group :gender
        f.submit
      end
    end
  end
end
