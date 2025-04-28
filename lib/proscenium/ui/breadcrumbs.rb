# frozen_string_literal: true

module Proscenium::UI
  # Provides breadcrumb functionality for controllers and views. Breadcrumbs are a type of
  # navigation that show the user where they are in the application's hierarchy.
  # The `Proscenium::UI::Breadcrumbs::Control` module provides the `add_breadcrumb` and
  # `prepend_breadcrumb` class methods for adding breadcrumb elements, and is intended to be
  # included in your controllers.
  #
  # The `add_breadcrumb` method adds a new breadcrumb element to the end of the collection, while
  # the `prepend_breadcrumb` method adds a new breadcrumb element to the beginning of the
  # collection. Both methods take a name, and path as arguments. The name argument is the name or
  # content of the breadcrumb, while the path argument is the path (route) to use as the HREF for
  # the breadcrumb.
  #
  #   class UsersController < ApplicationController
  #     include Proscenium::UI::Breadcrumbs::Control
  #     add_breadcrumb 'Users', :users_path
  #   end
  #
  # Display the breadcrumbs in your views with the breadcrumbs component.
  # @see `Proscenium::UI::Breadcrumbs::Component`.
  #
  # At it's simplest, you can add a breadcrumb with a name of "User", and a path of "/users" like
  # this:
  #
  #   add_breadcrumb 'Foo', '/foo'
  #
  # The value of the path is always passed to `url_for` before being rendered. It is also optional,
  # and if omitted, the breadcrumb will be rendered as plain text.
  #
  # Both name and path can be given a Symbol, which can be used to call a method of the same name on
  # the controller. If a Symbol is given as the path, and no method of the same name exists, then
  # `url_for` will be called with the Symbol as the argument. Likewise, if an Array is given as the
  # path, then `url_for` will be called with the Array as the argument.
  #
  # If a Symbol is given as the path or name, and it begins with `@` (eg. `:@foo`), then the
  # instance variable of the same name will be called.
  #
  #   add_breadcrumb :@foo, :@bar
  #
  # A Proc can also be given as the name and/or path. The Proc will be called within the context of
  # the controller.
  #
  #   add_breadcrumb -> { @foo }, -> { @bar }
  #
  # Passing an object that responds to `#for_breadcrumb` as the name will call that method on the
  # object to get the breadcrumb name.
  #
  class Breadcrumbs < Component
    include Phlex::Rails::Helpers::URLFor
    extend Literal::Properties

    # The path (route) to use as the HREF for the home segment. Defaults to `:root`.
    prop :home_path, _Union(String, Symbol), default: -> { :root }

    # Assign false to hide the home segment.
    prop :with_home, _Boolean, default: -> { true }

    def self.css_module_path = source_path.sub_ext('').join('index.module.css')

    def view_template(&block)
      ap block
      div class: :@base do
        ol do
          if @with_home
            li do
              yield if block_given?
              home_template
            end
          end

          breadcrumbs.each do |ce|
            li do
              path = ce.path
              path.nil? ? ce.name : a(href: url_for(path)) { ce.name }
            end
          end
        end
      end
    end

    private

      # Override this to customise the home breadcrumb. You can call super with a block to use the
      # default template, but with custom content.
      #
      # @example
      #  def home_template
      #    super { 'hello' }
      #  end
      def home_template(&block)
        a(href: url_for(@home_path)) do
          if block
            yield
          else
            svg role: 'img', xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 576 512' do |s|
              s.path fill: 'currentColor', d: <<~SVG.gsub("\n", '')
                M488 312.7V456c0 13.3-10.7 24-24 24H348c-6.6 0-12-5.4-12-12V356c0-6.6-5.4-
                12-12-12h-72c-6.6 0-12 5.4-12 12v112c0 6.6-5.4 12-12 12H112c-13.3 0-24-10.
                7-24-24V312.7c0-3.6 1.6-7 4.4-9.3l188-154.8c4.4-3.6 10.8-3.6 15.3 0l188 15
                4.8c2.7 2.3 4.3 5.7 4.3 9.3zm83.6-60.9L488 182.9V44.4c0-6.6-5.4-12-12-12h-
                56c-6.6 0-12 5.4-12 12V117l-89.5-73.7c-17.7-14.6-43.3-14.6-61 0L4.4 251.8c
                -5.1 4.2-5.8 11.8-1.6 16.9l25.5 31c4.2 5.1 11.8 5.8 16.9 1.6l235.2-193.7c4
                .4-3.6 10.8-3.6 15.3 0l235.2 193.7c5.1 4.2 12.7 3.5 16.9-1.6l25.5-31c4.2-5
                .2 3.4-12.7-1.7-16.9z
              SVG
            end
          end
        end
      end

      # Don't render if @hide_breadcrumbs is true.
      def render?
        helpers.assigns['hide_breadcrumbs'] != true
      end

      def breadcrumbs
        helpers.controller.breadcrumbs.map { |e| Breadcrumbs::ComputedElement.new e, helpers }
      end
  end
end
