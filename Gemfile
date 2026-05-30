# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in proscenium-ui.gemspec.
gemspec

gem 'puma'
gem 'rails'
gem 'sqlite3'

gem 'amazing_print'
gem 'debug', '>= 1.0.0'
gem 'icons'
gem 'phlexible'
gem 'rails_icons'
gem 'redcarpet'
gem 'rouge'

gem 'appraisal', require: false
# parallel 2.x (a RuboCop dependency) requires Ruby >= 3.3; pin to 1.x so the gem's
# supported Ruby floor (3.2, per the gemspec) still bundles and tests in CI.
gem 'parallel', '< 2', require: false
gem 'rubocop-capybara', require: false
gem 'rubocop-disable_syntax', require: false
gem 'rubocop-minitest', require: false
gem 'rubocop-packaging', require: false
gem 'rubocop-performance', require: false
gem 'rubocop-rails', require: false

group :development do
  gem 'rails_caddy_dev'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'capybara-playwright-driver'
  # Keep in lockstep with the `playwright` version pinned in package.json: the Ruby client and the
  # JS-installed browser must share the same minor version (see application_system_test_case.rb).
  gem 'playwright-ruby-client', '~> 1.59.0'
  # maxitest 7 requires minitest 6, whose test-runner API is incompatible with Rails 7.2's
  # line filtering. Pin below 7 (minitest 5.x) so the whole supported Rails range stays testable.
  gem 'maxitest', '< 7'
  gem 'minitest-difftastic'
  gem 'minitest-focus'
  gem 'minitest-spec-rails'
  gem 'rainbow', require: false
end
