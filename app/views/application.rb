# frozen_string_literal: true

class Views::Application < Phlex::HTML
  include Proscenium::Phlex::CssModules
  include Proscenium::Phlex::Sideload
  include Phlexible::PageTitle
  include Phlexible::Rails::AElement

  register_output_helper :icon
  delegate :request, :controller, :params, :icon, to: :view_context

  self.page_title = Rails.application.class.name.deconstantize
end
