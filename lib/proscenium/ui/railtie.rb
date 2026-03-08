# frozen_string_literal: true

module Proscenium
  module UI
    class Railtie < ::Rails::Railtie
      initializer 'proscenium-ui.reloader' do |app|
        next if !Proscenium::UI::LOADER.reloading_enabled?

        lib_path = File.expand_path('../..', __dir__)

        checker = app.config.file_watcher.new([], { lib_path => [:rb] }) do
          Proscenium::UI::LOADER.reload
        end

        app.reloaders << checker

        app.reloader.to_run do
          checker.execute_if_updated
        end
      end
    end
  end
end
