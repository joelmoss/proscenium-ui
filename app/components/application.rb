# frozen_string_literal: true

class Components::Application < Phlex::HTML
  include Proscenium::Phlex::CssModules
  include Proscenium::Phlex::Sideload
  include Phlexible::Rails::AElement

  register_output_helper :icon
  delegate :request, :controller, :params, :icon, to: :view_context
end
