# frozen_string_literal: true

module Views
  class Combobox::MultiSelect < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Combobox'

    def view_template
      render Proscenium::UI::Combobox.new(
        name: 'tags',
        placeholder: 'Add tags...',
        options: %w[Ruby Rails JavaScript TypeScript Python Go Rust],
        multiple: true,
        value: %w[Ruby Rails]
      )
    end
  end
end
