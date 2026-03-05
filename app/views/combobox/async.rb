# frozen_string_literal: true

module Views
  class Combobox::Async < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Combobox'

    def view_template
      h3 { 'Remote search' }
      p { 'Type at least 2 characters to search.' }
      render Proscenium::UI::Combobox.new(
        name: 'user_id',
        src: '/combobox/users',
        placeholder: 'Search users...',
        min_chars: 2,
        debounce: 300
      )

      h3 { 'Remote multi-select with pre-selected values' }
      render Proscenium::UI::Combobox.new(
        name: 'assignee_ids',
        src: '/combobox/users',
        placeholder: 'Search assignees...',
        multiple: true,
        value: ['1'],
        selected_options: [label: 'Alice', value: '1']
      )
    end
  end
end
