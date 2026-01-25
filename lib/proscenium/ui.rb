# frozen_string_literal: true

require 'zeitwerk'
require 'proscenium/ui/railtie'

# Don't use Zeitwerk in development when running the gem locally, since it causes issues when this
# gem is used by another rails app.
if !ENV.key?('PUI_ENV')
  loader = Zeitwerk::Loader.for_gem_extension(Proscenium)
  loader.inflector.inflect('ui' => 'UI', 'ujs' => 'UJS')
  loader.setup
end

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
