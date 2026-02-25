# frozen_string_literal: true

class BreadcrumbsController < ApplicationController
  include Proscenium::UI::Breadcrumbs::Control

  add_breadcrumb 'Foo', '/foo'
  add_breadcrumb 'Bar', '/foo/bar'
  add_breadcrumb 'Baz'
end
