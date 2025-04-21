# frozen_string_literal: true

module Proscenium::UI
  # Base class for all Proscenium components. This class provides a common interface for all
  # components, including rendering, CSS modules, and other shared functionality.
  #
  # @abstract
  class Component < Proscenium::Phlex
    self.abstract_class = true
  end
end
