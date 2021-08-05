# frozen_string_literal: true

require 'active_record/base'
puts 'DatabaseTasks'
module ActiveRecord
  module ConnectionAdapters
    module TiDB
      class DatabaseTasks < ActiveRecord::Tasks::MySQLDatabaseTasks
      end
    end
  end
end

ActiveRecord::Tasks::DatabaseTasks.register_task(/tidb/, ActiveRecord::ConnectionAdapters::TiDB::DatabaseTasks)
