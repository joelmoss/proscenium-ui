# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require_relative '../test/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
require 'rails/test_help'
require 'maxitest/autorun'
require 'capybara/rails'
require 'capybara/minitest'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [File.expand_path('fixtures', __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = "#{File.expand_path('fixtures', __dir__)}/files"
  ActiveSupport::TestCase.fixtures :all
end

COMPONENTS_PATH = '/node_modules/@rubygems/proscenium-ui/lib/proscenium/ui'

module ActiveSupport
  class TestCase
    before do
      Proscenium.config.side_load = true
      Proscenium::Importer.reset
      Proscenium::Resolver.reset
    end

    class << self
      alias with context

      def view(*args, **kwargs, &block)
        define_method :view do
          @view ||= Capybara::Node::Simple.new(if block
                                                 view_context.render instance_eval(&block)
                                               else
                                                 render(*args, **kwargs)
                                               end)
        end
      end
    end

    if !method_defined?(:view)
      def view
        @view ||= Capybara::Node::Simple.new(render)
      end
    end

    delegate :view_context, to: :controller

    def controller
      @controller ||= ActionView::TestCase::TestController.new
    end

    def subject(...)
      described_class.new(...)
    end

    def render(...)
      view_context.render subject(...)
    end
  end
end
