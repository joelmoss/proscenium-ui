# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Phlexible::Rails::ActionController::ImplicitRender

  private

    def phlex_view_path(action_name)
      "views/#{controller_path}/#{action_name}"
    end
end
