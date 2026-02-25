# frozen_string_literal: true

module Views
  class Layouts::Application < Application
    extend Literal::Properties
    include Proscenium::Phlex::IncludeAssets
    include Phlex::Rails::Helpers::CSPMetaTag
    include Phlex::Rails::Helpers::CSRFMetaTags

    prop :view, _Nilable(Views::Application), :positional

    def view_template(&)
      doctype
      html do
        head do
          title { @view&.try(:page_title) || controller.try(:page_title) || page_title }
          meta name: 'viewport', content: 'width=device-width, initial-scale=1'
          meta name: 'color-scheme', content: 'light dark'
          link rel: :icon, href: 'data:,'
          csp_meta_tag
          csrf_meta_tags
          include_assets
        end
        body do
          div class: :@root do
            aside do
              header do
                h1 { 'Proscenium::UI' }
                render Components::Navigation
              end
            end
            main data: { viewport: controller.viewport } do
              if controller.action_name == 'landing'
                render_landing
              else
                render_preview
              end
            end
          end
        end
      end
    end

    private

      def render_landing
        readme = controller.send(:readme_html)
        if readme
          div(class: :@readme) { raw readme } # rubocop:disable Rails/OutputSafety
        else
          div(class: :@placeholder) do
            p { "No documentation yet for #{controller.controller_name.titleize}." }
          end
        end
      end

      def render_preview
        div class: :@toolbar do
          button type: :button, data: { color_scheme_toggle: controller.color_scheme } do
            span(data: { icon: :light },
                 hidden: controller.color_scheme != :dark || nil) do
              icon :sun, variant: :outline
            end
            span(data: { icon: :dark },
                 hidden: controller.color_scheme != :light || nil) do
              icon :moon, variant: :outline
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
        div class: :@resizer, data: { resizer: true }
        render Components::SourcePanel.new(@view)
      end

      def iframe_src
        "/bare#{request.path}"
      end
  end
end
