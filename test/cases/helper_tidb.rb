# frozen_string_literal: true

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

# DIAGNOSTIC (do not merge): report which test leaves rows in contracts.
module TiDBContractsLeakCheck
  def after_teardown
    super
    conn = ActiveRecord::Base.connection
    rows = conn.select_rows('SELECT company_id, COUNT(*) FROM contracts GROUP BY company_id ORDER BY company_id')
    sig = rows.inspect
    if sig != $tidb_contracts_last
      $stderr.puts "\n[CONTRACTS-LEAK] after #{self.class.name}##{name}: #{sig} (open_tx=#{conn.open_transactions})"
      $tidb_contracts_last = sig
    end
  rescue StandardError => e
    $stderr.puts "\n[CONTRACTS-LEAK] check failed after #{self.class.name}##{name}: #{e.class}: #{e.message[0, 120]}"
  end
end
ActiveRecord::TestCase.prepend(TiDBContractsLeakCheck)

# DIAGNOSTIC (do not merge): log every SQL statement with the connection it ran on.
if ENV['DIAG_SQL']
  ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
    conn = payload[:connection]
    $stdout.puts "[SQL conn=#{conn&.object_id} tx=#{conn&.open_transactions}] #{payload[:name]}: #{payload[:sql][0, 300]}"
  end
  module TiDBDiagBoundaries
    def before_setup
      $stdout.puts "[TEST-BEGIN] #{self.class.name}##{name} base_conn=#{ActiveRecord::Base.connection.object_id}"
      super
    end

    def after_teardown
      super
      $stdout.puts "[TEST-END] #{self.class.name}##{name} base_conn=#{ActiveRecord::Base.connection.object_id}"
    end
  end
  ActiveRecord::TestCase.prepend(TiDBDiagBoundaries)
end
