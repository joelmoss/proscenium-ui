# frozen_string_literal: true

require 'proscenium/phlex'
require 'literal'

module Proscenium::UI
  class Component < Phlex::HTML
    extend Literal::Properties
    include Proscenium::Phlex::Sideload
    include Proscenium::Phlex::CssModules

    self.abstract_class = true
    sideload_assets js: { type: 'module' }

    delegate :controller, to: :view_context
  end
end
