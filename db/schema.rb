# frozen_string_literal: true

# This project keeps its canonical schema at test/fixtures/db/schema.rb (it
# describes the test fixture models, not application data). This stub exists
# so Rails' rake tasks — particularly the parallel system-test database setup
# under `bin/rails test:system` — can find a schema at the conventional
# location.
load File.expand_path('../test/fixtures/db/schema.rb', __dir__)
