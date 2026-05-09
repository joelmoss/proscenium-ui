# frozen_string_literal: true

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = ENV.key?('CI')
  config.public_file_server.enabled = true
  config.public_file_server.headers = { 'cache-control' => 'public, max-age=3600' }
  config.consider_all_requests_local = true
  config.cache_store = :null_store
  config.action_dispatch.show_exceptions = :rescuable
  config.action_controller.allow_forgery_protection = false
  config.active_support.deprecation = :stderr
  config.action_controller.raise_on_missing_callback_actions = true
  config.proscenium.ensure_loaded = :ignore

  # Schema lives at test/fixtures/db/schema.rb and is loaded explicitly by
  # test_helper.rb; disable Rails' canonical-db/schema.rb check so the
  # `rails test` / `rails test:system` rake tasks don't warn or hang on it.
  config.active_record.maintain_test_schema = false
end
