# frozen_string_literal: true

require 'active_record/connection_adapters'
require 'active_record/connection_adapters/mysql2_adapter'
require 'active_record/connection_adapters/tidb/setup'
require_relative '../../version'

ActiveRecord::ConnectionAdapters::Tidb.initial_setup

module ActiveRecord
  module ConnectionHandling #:nodoc:
    # Establishes a connection to the database that's used by all Active Record objects.
    def tidb_connection(config) #:nodoc:
      config = config.symbolize_keys
      config[:flags] ||= 0

      if config[:flags].is_a? Array
        config[:flags].push 'FOUND_ROWS'
      else
        config[:flags] |= Mysql2::Client::FOUND_ROWS
      end

      ConnectionAdapters::TidbAdapter.new(
        ConnectionAdapters::Mysql2Adapter.new_client(config),
        logger,
        nil,
        config
      )
    end
  end

  module ConnectionAdapters
    class TidbAdapter < Mysql2Adapter
      ADAPTER_NAME = 'Tidb'

      def supports_savepoints?
        false
      end

      def supports_foreign_keys?
        false
      end

      def supports_bulk_alter?
        false
      end

      def supports_advisory_locks?
        false
      end

      def supports_optimizer_hints?
        true
      end

      def supports_json?
        true
      end

      def supports_index_sort_order?
        # TODO: check TiDB version
        true
      end

      def supports_expression_index?
        true
      end

      def supports_common_table_expressions?
        true
      end

      def transaction_isolation_levels
        {
          read_committed: 'READ COMMITTED',
          repeatable_read: 'REPEATABLE READ'
        }
      end

      def initialize(connection, logger, conn_params, config)
        super(connection, logger, conn_params, config)

        tidb_version_string = query_value('select version()')
        @tidb_version = tidb_version_string[/TiDB-v(.*?)-/, 1]
      end

      def tidb_version_string
        @tidb_version
      end

      def tidb_version
        Version.new(tidb_version_string)
      end

      def self.database_exists?(config)
        !!ActiveRecord::Base.tidb_connection(config)
      rescue ActiveRecord::NoDatabaseError
        false
      end
    end
  end
end
