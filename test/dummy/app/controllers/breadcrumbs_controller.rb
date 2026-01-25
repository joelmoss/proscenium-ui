# frozen_string_literal: true

class BreadcrumbsController < ApplicationController
  include Proscenium::UI::Breadcrumbs::Control

  add_breadcrumb 'Users', :users_path
end
