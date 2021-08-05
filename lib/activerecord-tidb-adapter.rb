# frozen_string_literal: true

if defined?(Rails)
  module ActiveRecord
    module ConnectionAdapters
      class TidbRailtie < ::Rails::Railtie
        rake_tasks do
          load 'active_record/connection_adapters/tidb/database_tasks.rb'
        end
      end
    end
  end
end
