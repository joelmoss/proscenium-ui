# frozen_string_literal: true

require 'proscenium/ui/railtie'
require 'proscenium/phlex'
require 'literal'

require 'zeitwerk'

module Proscenium
  module UI
    LOADER = Zeitwerk::Loader.for_gem_extension(Proscenium)
    LOADER.inflector.inflect('ui' => 'UI', 'ujs' => 'UJS')
    LOADER.enable_reloading if defined?(Rails.root) && Rails.env.development? &&
                               __dir__.start_with?(Rails.root.to_s)
    LOADER.setup

    class << self
      def method_missing(name, ...)
        if methods.exclude?(name) && name[0] == name[0].upcase && const_defined?(name) &&
           const_get(name) < Component
          define_singleton_method(name) do |*args, **kwargs, &block|
            const_get(name).new(*args, **kwargs, &block)
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
