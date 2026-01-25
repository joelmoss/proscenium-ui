# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require_relative '../test/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
require 'rails/test_help'
require 'minitest/difftastic'
require 'maxitest/autorun'
require 'capybara/rails'
require 'capybara/minitest'

COMPONENTS_PATH = '/node_modules/@rubygems/proscenium-ui/lib/proscenium/ui'

module ActiveSupport
  class TestCase
    include Capybara::DSL
    include Capybara::Minitest::Assertions # Make `assert_*` methods behave like Minitest assertions

    setup do
      Proscenium::Importer.reset
      Proscenium::Resolver.reset
    end

    teardown do
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end

    class << self
      alias with context
      def view(...); end

      def render_subject(*args, **kwargs, &block)
        if (!args.empty? || !kwargs.empty?) && !block.nil?
          raise ArgumentError, %(
            Cannot provide both arguments and a block to `render_subject`. Choose one or the other.
          )
        end

        define_method :to_render do
          if block
            args = instance_eval(&block)
            blk = args.pop if args.last.is_a?(Proc)
            kwargs = args.extract_options!
          end
          @to_render ||= described_class.new(*args, **kwargs, &blk)
        end
      end
    end

    def page
      subject
    end

    def subject
      @subject ||= render
    end

    def html
      subject
      @html
    end

    def render_subject(*, **)
      @html = view_context.render(described_class.new(*, **))
      @subject = Capybara.string(@html)
    end

    def render
      @html = view_context.render(to_render)
      @subject = Capybara.string(@html)
    end

    private

      def view_context
        controller.view_context
      end

      def controller
        @controller ||= ActionView::TestCase::TestController.new
      end
  end
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions # Make `assert_*` methods behave like Minitest assertions

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
    Proscenium::Importer.reset
    Proscenium::Resolver.reset
  end
end
