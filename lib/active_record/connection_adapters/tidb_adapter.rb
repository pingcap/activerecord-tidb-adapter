# frozen_string_literal: true

require 'active_record/connection_adapters'
require 'active_record/connection_adapters/mysql2_adapter'
require 'active_record/connection_adapters/tidb/setup'
require_relative '../../version'
require_relative '../sequence'
require_relative 'tidb/schema_statements' unless tidb_version >= '5.2.0'
# https://github.com/pingcap/tidb/issues/26110 has been fixed since TiDB 5.2.0 or higher
# via https://github.com/pingcap/tidb/commit/1641b3411d663eb67464a34882a3f222b67cea8d
require_relative 'tidb/database_statements'

ActiveRecord::ConnectionAdapters::Tidb.initial_setup

module ActiveRecord
  module ConnectionHandling # :nodoc:
    # Establishes a connection to the database that's used by all Active Record objects.
    def tidb_connection(config) # :nodoc:
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
      include ActiveRecord::Sequence::Adapter
      ADAPTER_NAME = 'Tidb'

      def supports_savepoints?
        # https://github.com/pingcap/tidb/issues/6840 support is required
        false
      end

      def supports_foreign_keys?
        # https://github.com/pingcap/tidb/issues/18209 support is required
        false
      end

      def supports_bulk_alter?
        # https://github.com/pingcap/tidb/issues/14766 support is required
        false
      end

      def supports_advisory_locks?
        # https://github.com/pingcap/tidb/issues/14994 support is required
        false
      end

      def supports_optimizer_hints?
        true
      end

      def supports_json?
        true
      end

      def supports_index_sort_order?
        # https://github.com/pingcap/tidb/issues/2519 support is required
        false
      end

      def supports_expression_index?
        sql = <<~SQL
          SELECT VALUE 
          FROM INFORMATION_SCHEMA.CLUSTER_CONFIG 
          WHERE `KEY` = 'experimental.allow-expression-index' AND `TYPE` = 'tidb'
        SQL
        query_value(sql) == 'true'
      end

      def supports_common_table_expressions?
        tidb_version >= '5.1.0'
      end

      def initialize(connection, logger, conn_params, config)
        super(connection, logger, conn_params, config)

        tidb_version_string = query_value('select version()')
        @tidb_version = tidb_version_string[/TiDB-v([0-9.]+)/, 1]
      end

      def tidb_version_string
        @tidb_version
      end

      def tidb_version
        Version.new(tidb_version_string)
      end

      def self.database_exists?(config)
        !ActiveRecord::Base.tidb_connection(config).nil?
      rescue ActiveRecord::NoDatabaseError
        false
      end

      def new_column_from_field(_table_name, field)
        type_metadata = fetch_type_metadata(field[:Type], field[:Extra])
        default = field[:Default]
        default_function = nil

        if type_metadata.type == :datetime && /\ACURRENT_TIMESTAMP(?:\([0-6]?\))?\z/i.match?(default)
          default = "#{default} ON UPDATE #{default}" if /on update CURRENT_TIMESTAMP/i.match?(field[:Extra])
          default_function = default
          default = nil
        elsif type_metadata.extra == 'DEFAULT_GENERATED'
          default = +"(#{default})" unless default.start_with?('(')
          default_function = default
          default = nil
        elsif default.to_s =~ /nextval/i
          default_function = default
          default = nil
        end

        MySQL::Column.new(
          field[:Field],
          default,
          type_metadata,
          field[:Null] == 'YES',
          default_function,
          collation: field[:Collation],
          comment: field[:Comment].presence
        )
      end
    end
  end
end
