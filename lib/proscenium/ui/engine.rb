# frozen_string_literal: true

module Proscenium
  module UI
    class Engine < ::Rails::Engine
      isolate_namespace Proscenium::UI

      # initializer 'proscenium-ui.paths' do |app|
      # config.autoload_paths << "#{root}/app/components"
      # config.autoload_paths << "#{root}/lib/proscenium/ui"
      # pp config.autoload_paths
      # end

      initializer 'proscenium-ui.public_path' do |app|
        if app.config.public_file_server.enabled
          headers = app.config.public_file_server.headers || {}
          index = app.config.public_file_server.index_name || 'index'

          app.middleware.insert_after(ActionDispatch::Static, ActionDispatch::Static,
                                      root.join('public').to_s, index:, headers:)
        end
      end
    end
  end
end
