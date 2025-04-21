# frozen_string_literal: true

# Represents a navigation element in the breadcrumb collection.
class Proscenium::UI::Breadcrumbs::Element
  attr_accessor :name, :path, :options

  # @param  name [String] the element/link name
  # @param  path [String] the element/link URL
  # @param  options [Hash] the element/link options
  # @return [Element]
  def initialize(name, path = nil, options = {})
    self.name = name
    self.path = path
    self.options = options
  end
end
