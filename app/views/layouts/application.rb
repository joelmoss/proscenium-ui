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
            main data: { viewport: controller.viewport } do
              div class: :@toolbar do
                if controller.color_scheme == :light
                  a href: color_scheme_path(:dark) do
                    icon :moon, variant: :outline
                  end
                else
                  a href: color_scheme_path(:light) do
                    icon :moon, variant: :solid
                  end
                end

                div class: :@toggle_group, role: :group do
                  button type: :button,
                         aria_pressed: (controller.viewport == :desktop).to_s,
                         data: { viewport_btn: :desktop } do
                    icon :'computer-desktop', variant: :outline
                  end
                  button type: :button,
                         aria_pressed: (controller.viewport == :mobile).to_s,
                         data: { viewport_btn: :mobile } do
                    icon :'device-phone-mobile', variant: :outline
                  end
                end

                a href: iframe_src, target: '_blank', title: 'Open in new tab',
                  style: 'margin-left: auto' do
                  icon :'arrow-top-right-on-square', variant: :outline
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
