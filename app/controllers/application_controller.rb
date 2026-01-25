# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Phlexible::Rails::ActionController::ImplicitRender

  before_action :assign_layout, :assign_color_scheme

  def color_scheme
    (session[:color_scheme] || 'light').to_sym
  end

  private

    def phlex_view_path(action_name)
      "views/#{controller_path}/#{action_name}"
    end

    def assign_layout
      @layout = Views::Layouts::Bare if request.path.start_with?('/bare')
    end

    def assign_color_scheme
      session[:color_scheme] = params[:color_scheme] if params[:color_scheme].in?(%w[light dark])
    end
end
