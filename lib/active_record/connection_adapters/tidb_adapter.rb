# frozen_string_literal: true

require 'active_record/connection_adapters'
require 'active_record/connection_adapters/mysql2_adapter'
require 'active_record/connection_adapters/tidb/setup'
require_relative '../../version'
require_relative '../sequence'

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
        false
      end

      def supports_common_table_expressions?
        tidb_version >= '5.1.0'
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

      def insert(arel, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
        sql, binds = to_sql_and_binds(arel, binds)
        value = exec_insert(sql, name, binds, pk, sequence_name)
        return id_value if id_value.present?
        return last_inserted_id(value) if arel.is_a?(String)
        model = arel.ast.relation.instance_variable_get(:@klass)
        pk_def = schema_cache.columns_hash(model.table_name)[pk]
        if pk_def&.default_function && pk_def.default_function =~ /nextval/
          query_value("SELECT #{pk_def.default_function.sub('nextval', 'lastval')}")
        else
          last_inserted_id(value)
        end
      end
      alias create insert

      def new_column_from_field(_table_name, field)
        type_metadata = fetch_type_metadata(field[:Type], field[:Extra])
        default = field[:Default]
        default_function = nil

        if type_metadata.type == :datetime && /\ACURRENT_TIMESTAMP(?:\([0-6]?\))?\z/i.match?(default)
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
