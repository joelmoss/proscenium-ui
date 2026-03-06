# frozen_string_literal: true

module Views
  class Flash::Types < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Flash'

    def view_template
      render Proscenium::UI::Flash
    end
  end
end
