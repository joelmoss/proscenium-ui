# frozen_string_literal: true

require 'test_helper'
require 'capybara/rails'
require 'rainbow'

require_relative '../config/routes'

# Setup Playwright with compatible version
#
#   export PLAYWRIGHT_CLI_VERSION=$(bundle exec ruby -e 'require "playwright"; puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip')
#   pnpm add -D playwright@$PLAYWRIGHT_CLI_VERSION
#   pnpm playwright install

Capybara.register_driver :my_playwright do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: ENV['PLAYWRIGHT_BROWSER']&.to_sym || :chromium,
    # -> failing with `ArgumentError: unknown keyword: :devtools`
    # devtools: ENV.key?('PLAYWRIGHT_DEVTOOLS'),
    headless: ENV['CI'] || !ENV.fetch('PLAYWRIGHT_HEADED', nil)
  )
end

Capybara.default_max_wait_time = 10
Capybara.javascript_driver = :my_playwright

# Reduce extra logs produced by puma booting up
Capybara.server = :puma, { Silent: true }

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  parallelize
  driven_by :my_playwright

  # Use Capybara's page method, not the unit test override from ActiveSupport::TestCase
  def page
    Capybara.current_session
  end

  PLAYWRIGHT_ASSERTIONS = Playwright::PageAssertions.instance_methods(false) +
                          Playwright::LocatorAssertions.instance_methods(false)
  PLAYWRIGHT_ASSERTIONS.each do |method_name|
    assertion_name = method_name.to_s
                                .gsub('not_to_', 'refute_')
                                .gsub('to_', 'assert_')
                                .gsub('_have_', '_has_')
                                .gsub('_be_', '_')

    define_method assertion_name do |actual, *args, **kwargs|
      Playwright::Test::Expect.new.call(actual, false).send(method_name, *args, **kwargs)
      assert true # rubocop:disable Minitest/UselessAssertion
    rescue Playwright::AssertionError => e
      assert false, e.full_message # rubocop:disable Minitest/AssertWithExpectedArgument
    end
  end

  before do
    @console_log = ConsoleLog.new

    page.driver.with_playwright_page do |page|
      page.on('pageerror', lambda { |err|
        failures << begin
          raise Minitest::Assertion, err.stack
        rescue Minitest::Assertion => e
          e
        end
      })

      page.on 'console', @console_log
    end
  end

  after do
    @tagged_logger.debug "\nBrowser Console Logs:\n#{@console_log}\n"
  end

  class ConsoleLog
    LOG_LEVELS = %w[log debug].freeze
    GROUP_LEVELS = %w[startGroupCollapsed startGroup].freeze

    def initialize
      @log = []
      @grouped = false
    end

    def call(message)
      if GROUP_LEVELS.include?(message.type)
        @log << Rainbow("  #{prettify(message)}").blue
        @grouped = true
      elsif message.type == 'endGroup'
        @grouped = false
      elsif LOG_LEVELS.include?(message.type)
        @log << Rainbow(prettify(message).prepend(@grouped ? '   > ' : '  ')).blue
      elsif message.type == 'warning'
        @log << Rainbow(prettify(message).prepend(@grouped ? '   > ' : '  ')).orange
      elsif message.type == 'error'
        @log << Rainbow(prettify(message).prepend(@grouped ? '   > ' : '  ')).red
      end
    end

    def to_s
      @log.join("\n")
    end

    def prettify(message)
      if message.args.many?
        args = message.args[1..].map { it.instance_variable_get :@impl }
        format message.args.first.to_s.gsub('%o', '%p'), *args
      else
        message.text
      end
    end
  end
end
