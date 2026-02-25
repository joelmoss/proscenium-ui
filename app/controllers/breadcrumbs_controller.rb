# frozen_string_literal: true

class BreadcrumbsController < ApplicationController
  include Proscenium::UI::Breadcrumbs::Control

  def index
    add_breadcrumb 'Foo', '/foo'
    add_breadcrumb 'Bar', '/foo/bar'
    add_breadcrumb 'Baz'
  end

  def custom_css
    add_breadcrumb 'Foo', '/foo'
    add_breadcrumb 'Bar', '/foo/bar'
    add_breadcrumb 'Baz'
  end
end
