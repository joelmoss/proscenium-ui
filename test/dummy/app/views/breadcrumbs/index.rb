# frozen_string_literal: true

module Views
  class Breadcrumbs::Index < Proscenium::Phlex
    def view_template
      render Proscenium::UI::Breadcrumbs
    end
  end
end
