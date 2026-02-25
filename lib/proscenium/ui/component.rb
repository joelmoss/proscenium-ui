# frozen_string_literal: true

require 'proscenium/phlex'
require 'literal'

module Proscenium::UI
  extend Phlex::Kit

  class Component < Phlex::HTML
    extend Literal::Properties
    include Proscenium::Phlex::Sideload
    include Proscenium::Phlex::CssModules

    self.abstract_class = true
    sideload_assets js: { type: 'module' }

    delegate :controller, to: :view_context

    # Support Phlex v1 and 2
    alias view_context helpers if Gem::Version.new(Phlex::VERSION) < Gem::Version.new('2')
  end
end
