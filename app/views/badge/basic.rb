# frozen_string_literal: true

module Views
  class Badge::Basic < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Badge'

    def view_template
      Proscenium::UI::Badge('Active')
    end
  end
end
