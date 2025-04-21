# frozen_string_literal: true

require 'proscenium/ui/engine'
require 'proscenium'
require 'zeitwerk'
require 'phlex'

loader = Zeitwerk::Loader.for_gem_extension(Proscenium)
loader.inflector.inflect('ui' => 'UI')
loader.setup

module Proscenium::UI
  extend ::Phlex::Kit
end
