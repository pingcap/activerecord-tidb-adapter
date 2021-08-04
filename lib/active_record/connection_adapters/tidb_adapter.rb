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
    end
  end
end
