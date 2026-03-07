# frozen_string_literal: true

module Views
  class Badge::Types < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Badge'

    def view_template
      div(style: 'display: flex; gap: 0.5em; flex-wrap: wrap;') do
        Proscenium::UI::Badge('Default')
        Proscenium::UI::Badge('Success', variant: :success)
        Proscenium::UI::Badge('Warning', variant: :warning)
        Proscenium::UI::Badge('Danger', variant: :danger)
        Proscenium::UI::Badge('Info', variant: :info)
      end
    end
  end
end
