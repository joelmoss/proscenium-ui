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

COMPONENTS_PATH = '/node_modules/@rubygems/proscenium-ui/app/components/proscenium/ui'

module ViewHelper
  def self.extended(parent)
    parent.class_exec do
      delegate :view_context, to: :controller

      def controller
        @controller ||= ActionView::TestCase::TestController.new
      end
    end
  end

  def view(obj, &blk)
    let :instance do
      instance_exec(&obj)
    end

    let :view do
      result = if blk
                 instance.call(view_context:) do
                   instance.instance_exec(instance, &blk)
                 end
               else
                 view_context.render(instance)
               end

      Capybara::Node::Simple.new result
    end
  end
end

module ActiveSupport
  class TestCase
    extend ViewHelper

    before do
      Proscenium.config.side_load = true
      Proscenium::Importer.reset
      Proscenium::Resolver.reset
    end

    class << self
      alias with context
    end
  end
end
