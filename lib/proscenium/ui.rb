# frozen_string_literal: true

require 'proscenium/ui/railtie'
require 'proscenium/phlex'
require 'literal'

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem_extension(Proscenium)
loader.inflector.inflect('ui' => 'UI', 'ujs' => 'UJS')
loader.setup

module Proscenium
  module UI
    class << self
      def method_missing(name, ...)
        if methods.exclude?(name) && name[0] == name[0].upcase && const_defined?(name) &&
           (component = const_get(name)) < Component
          define_singleton_method(name) do |*args, **kwargs, &block|
            component.new(*args, **kwargs, &block)
          end
          public_send(name, ...)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        (methods.exclude?(name) && name[0] == name[0].upcase &&
         const_defined?(name) && const_get(name) < Component) || super
      end
    end
  end
end
