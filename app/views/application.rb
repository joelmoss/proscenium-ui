# frozen_string_literal: true

class Views::Application < Phlex::HTML
  include Proscenium::Phlex::CssModules
  include Proscenium::Phlex::Sideload
  include Phlexible::PageTitle
  include Phlexible::Rails::AElement

  delegate :request, :controller, :params, to: :view_context

  self.page_title = Rails.application.class.name.deconstantize
end
