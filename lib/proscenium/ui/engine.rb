# frozen_string_literal: true

module Proscenium
  module UI
    class Engine < ::Rails::Engine
      isolate_namespace Proscenium::UI
    end
  end
end
