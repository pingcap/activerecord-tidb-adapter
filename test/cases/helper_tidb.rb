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
