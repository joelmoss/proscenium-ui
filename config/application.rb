# frozen_string_literal: true

require_relative 'boot'

require 'debug'
require 'rails'

require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module Proscenium::UI
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.proscenium.logging = false
  end
end
