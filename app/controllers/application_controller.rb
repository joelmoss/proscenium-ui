# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Phlexible::Rails::ActionController::ImplicitRender

  before_action :assign_layout, :assign_color_scheme, :assign_viewport
  helper_method :readme_html

  def landing
    render Views::Layouts::Application.new, layout: false
  end

  def color_scheme
    (session[:color_scheme] || 'light').to_sym
  end

  def viewport
    (session[:viewport] || 'desktop').to_sym
  end

  private

    def phlex_view_path(action_name)
      "views/#{controller_path}/#{action_name}"
    end

    def readme_html
      path = Rails.root.join('app/views', controller_path, 'README.md')
      return nil if !path.exist?

      renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
      markdown = Redcarpet::Markdown.new(renderer, fenced_code_blocks: true, tables: true,
                                                    no_intra_emphasis: true, autolink: true)
      markdown.render(path.read).html_safe # rubocop:disable Rails/OutputSafety
    end

    def assign_layout
      @layout = Views::Layouts::Bare if request.path.start_with?('/bare')
    end

    def assign_color_scheme
      session[:color_scheme] = params[:color_scheme] if params[:color_scheme].in?(%w[light dark])
    end

    def assign_viewport
      session[:viewport] = params[:viewport] if params[:viewport].in?(%w[desktop mobile])
    end
end
