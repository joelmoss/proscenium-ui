# frozen_string_literal: true

module Views
  class Badge::Variants < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Badge'

    def view_template
      div(style: 'display: flex; gap: 0.5em; flex-wrap: wrap;') do
        render Proscenium::UI::Badge('Default')
        render Proscenium::UI::Badge('Success', variant: :success)
        render Proscenium::UI::Badge('Warning', variant: :warning)
        render Proscenium::UI::Badge('Danger', variant: :danger)
        render Proscenium::UI::Badge('Info', variant: :info)
      end
    end
  end
end
