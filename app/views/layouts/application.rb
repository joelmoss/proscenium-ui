# frozen_string_literal: true

module Views
  class Layouts::Application < Application
    extend Literal::Properties
    include Proscenium::Phlex::IncludeAssets
    include Phlex::Rails::Helpers::CSPMetaTag
    include Phlex::Rails::Helpers::CSRFMetaTags

    prop :view, Views::Application, :positional

    def view_template(&)
      doctype
      html do
        head do
          title { @view&.try(:page_title) || controller.try(:page_title) || page_title }
          meta name: 'viewport', content: 'width=device-width, initial-scale=1'
          meta name: 'color-scheme', content: 'light dark'
          csp_meta_tag
          csrf_meta_tags
          include_assets
        end
        body do
          div class: :@root do
            aside do
              header do
                h1 { 'Proscenium::UI' }
              end
              ul do
                li(data: { current: request.path.starts_with?('/breadcrumbs') }) do
                  a(href: :breadcrumbs) do
                    'Breadcrumbs'
                  end
                end
                li(data: { current: request.path.starts_with?('/forms') }) do
                  a(href: :forms) do
                    'Forms'
                  end
                end
              end
            end
            main do
              div class: :@toolbar do
                if controller.color_scheme == :light
                  a href: color_scheme_path(:dark) do
                    raw helpers.icon :moon, variant: :outline
                  end
                else
                  a href: color_scheme_path(:light) do
                    raw helpers.icon :moon, variant: :solid
                  end
                end
              end
              iframe src: iframe_src
            end
          end
        end
      end
    end

    private

      def iframe_src
        "/bare#{request.path}"
      end

      def color_scheme_path(scheme)
        "#{request.path}?#{Rack::Utils.build_query(color_scheme: scheme)}"
      end
  end
end
