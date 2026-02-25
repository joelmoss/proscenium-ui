# frozen_string_literal: true

module Components
  class Navigation < Application
    def view_template
      ul do
        controllers.each { |name, actions| nav_item(name, actions) }
      end
    end

    private

      def nav_item(name, actions)
        path = "/#{name}"
        current = request.path.start_with?(path)

        li(data: { current: current || nil }) do
          if actions.any?
            expandable_item(name, path, actions, open: current)
          else
            a(href: path) { name.titleize }
          end
        end
      end

      def expandable_item(name, path, actions, open:)
        details(open: open || nil) do
          summary do
            span { icon :'chevron-right', variant: :mini }
            plain name.titleize
          end
          action_list(path, actions)
        end
      end

      def action_list(path, actions)
        ul do
          nav_link(path, 'Default')
          actions.each { |action| nav_link("#{path}/#{action}", action.titleize) }
        end
      end

      def nav_link(href, label)
        li(data: { current: request.path == href || nil }) do
          a(href: href) { label }
        end
      end

      def controllers
        @controllers ||= controller_names.map { |name| [name, actions_for(name)] }
      end

      def controller_names
        Rails.root.join('app/controllers').children
             .select { |f| f.basename.to_s.end_with?('_controller.rb') }
             .map { |f| f.basename('.rb').to_s.delete_suffix('_controller') }
             .reject { |name| name == 'application' }
             .sort
      end

      def actions_for(controller_name)
        views_dir = Rails.root.join('app/views', controller_name)
        return [] if !views_dir.directory?

        views_dir.children
                 .filter_map { |f| f.basename('.rb').to_s if f.file? && f.extname == '.rb' }
                 .reject { |name| name == 'index' }
                 .sort
      end
  end
end
