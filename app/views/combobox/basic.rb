# frozen_string_literal: true

module Views
  class Combobox::Basic < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Combobox'

    def view_template
      render Proscenium::UI::Combobox.new(
        name: 'color',
        placeholder: 'Choose a colour...',
        options: %w[Red Orange Yellow Green Blue Indigo Violet]
      )
    end
  end
end
