# frozen_string_literal: true

require 'active_record/base'

module ActiveRecord
  module ConnectionAdapters
    module Tidb
      class DatabaseTasks < ActiveRecord::Tasks::MySQLDatabaseTasks
      end
    end
  end
end

ActiveRecord::Tasks::DatabaseTasks.register_task(/tidb/, ActiveRecord::ConnectionAdapters::Tidb::DatabaseTasks)
