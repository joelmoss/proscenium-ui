# frozen_string_literal: true

# Helps us identify that we are running local development of the gem.
ENV['PUI_ENV'] ||= 'development'

require_relative 'boot'
require 'debug'
require 'rails'
require 'active_record/railtie'
require 'action_view/railtie'

require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module Proscenium::UI
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.autoload_lib ignore: %w[assets tasks]

    config.proscenium.logging = false
  end
end
