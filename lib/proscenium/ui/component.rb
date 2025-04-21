# frozen_string_literal: true

module Proscenium::UI
  class Component < Proscenium::Phlex
    self.abstract_class = true
    sideload_assets js: { type: 'module' }
  end
end
