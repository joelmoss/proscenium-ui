# frozen_string_literal: true

module Views
  class Layouts::Bare < Application
    extend Literal::Properties
    include Proscenium::Phlex::IncludeAssets
    include Phlex::Rails::Helpers::CSPMetaTag
    include Phlex::Rails::Helpers::CSRFMetaTags

    prop :view, Views::Application, :positional

    def view_template(&)
      doctype
      html data: { color_scheme: controller.color_scheme } do
        head do
          title { @view&.try(:page_title) || controller.try(:page_title) || page_title }
          meta name: 'viewport', content: 'width=device-width, initial-scale=1'
          csp_meta_tag
          csrf_meta_tags
          include_assets
        end
        body(&)
      end
    end
  end
end
