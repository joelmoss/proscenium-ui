# frozen_string_literal: true

module Views
  class Breadcrumbs::Index < Application
    include Phlexible::Rails::AutoLayout

    self.page_title = 'Breadcrumbs'

    def view_template
      render Proscenium::UI::Breadcrumbs
    end
  end
end
