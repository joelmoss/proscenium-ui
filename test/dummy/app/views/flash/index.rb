# frozen_string_literal: true

module Views
  class Flash::Index < Proscenium::Phlex
    include Phlex::Rails::Helpers::Flash

    def view_template
      flash.notice = 'Hello!'
      render Proscenium::UI::Flash
    end
  end
end
