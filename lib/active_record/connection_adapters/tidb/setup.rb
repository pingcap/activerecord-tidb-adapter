# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    module Tidb
      def self.initial_setup
        ::ActiveRecord::SchemaDumper.ignore_tables |= %w[]
      end
    end
  end
end
