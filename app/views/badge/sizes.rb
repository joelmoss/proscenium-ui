# frozen_string_literal: true

module Views
  class Badge::Sizes < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Badge'

    def view_template
      div(style: 'display: flex; gap: 0.5em; align-items: center;') do
        render Proscenium::UI::Badge('Small', size: :sm)
        render Proscenium::UI::Badge('Medium')
        render Proscenium::UI::Badge('Large', size: :lg)
      end
    end
  end
end
