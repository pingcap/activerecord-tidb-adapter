# frozen_string_literal: true

# concurrent-ruby >= 1.3.5 no longer requires logger, and ActiveSupport
# before 7.0.8.7 references ::Logger without requiring it.
require 'logger'
require 'bundler/setup'
Bundler.require :development

# Turn on debugging for the test environment
ENV['DEBUG_TIDB_ADAPTER'] = '1'

# Load ActiveRecord test helper
require 'cases/helper'
require 'minitest/excludes'

def load_tidb_specific_schema
  # silence verbose schema loading
  original_stdout = $stdout
  $stdout = StringIO.new

  load 'schema/tidb_specific_schema.rb'

  ActiveRecord::FixtureSet.reset_cache
ensure
  $stdout = original_stdout
end

load_tidb_specific_schema
