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
  # Display the breadcrumbs in your view:
  #
  #   render Proscenium::UI::Breadcrumbs
  #
  # At it's simplest, you can add a breadcrumb with a name of "Users", and a path of "/users" like
  # this:
  #
  #   add_breadcrumb 'Users', '/users'
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

    register_element :pui_breadcrumbs
    register_element :pui_breadcrumbs_home
    register_element :pui_breadcrumbs_element

    # The path (route) to use as the HREF for the home segment. Defaults to `:root`.
    prop :home_path, _Union(String, Symbol), default: -> { :root }

    # Assign false to hide the home segment.
    prop :with_home, _Boolean, default: -> { true }

    def self.source_path
      super.sub_ext('').join('index.rb')
    end

    # For if and when we need to pass instance level css module.
    #
    # prop :css_module_path, _Nilable(Pathname)
    #
    # def css_module_path
    #   @css_module_path ||= self.class.css_module_path
    # end

    def view_template
      pui_breadcrumbs do
        if @with_home
          pui_breadcrumbs_home do
            yield if block_given?
            home_template
          end
        end

        breadcrumbs.each do |ce|
          pui_breadcrumbs_element do
            path = ce.path
            path.nil? ? ce.name : a(href: url_for(path)) { ce.name }
          end
        end
      end
    end

    # Override this to customise the home breadcrumb. You can call super with a block to use the
    # default template, but with custom content.
    #
    # @example
    #  def home_template
    #    super { 'hello' }
    #  end
    def home_template(&block)
      a href: url_for(@home_path) do
        if block
          yield
        else
          svg role: 'img', xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24',
              fill: 'currentColor' do |s|
            s.path d: <<~SVG.delete("\n")
              M11.47 3.841a.75.75 0 0 1 1.06 0l8.69 8.69a.75.75 0 1 0 1.06-1.061l-8.689
              -8.69a2.25 2.25 0 0 0-3.182 0l-8.69 8.69a.75.75 0 1 0 1.061 1.06l8.69-8.69Z
            SVG
            s.path d: <<~SVG.delete("\n")
              M12 5.432l8.159 8.159c.03.03.06.058.091.086v6.198c0 1.035-.84 1.875-1.875
              1.875H15.75a.75.75 0 0 1-.75-.75v-4.5a.75.75 0 0 0-.75-.75h-4.5a.75.75 0 0
              0-.75.75V21a.75.75 0 0 1-.75.75H5.625a1.875 1.875 0 0 1-1.875-1.875v-6.198
              a2.29 2.29 0 0 0 .091-.086L12 5.432Z
            SVG
          end
        end
      end
    end

    # Don't render if @hide_breadcrumbs is true.
    def render?
      controller.instance_variable_get(:@hide_breadcrumbs) != true
    end

    private

      def breadcrumbs
        controller.breadcrumbs.map do |e|
          Breadcrumbs::ComputedElement.new e, view_context
        end
      end
  end
end
