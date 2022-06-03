require 'active_record/connection_adapters/abstract/savepoints'

ActiveRecord::ConnectionAdapters::Savepoints.class_eval do
  
  def current_savepoint_name
    raise NotImplementedError, "Savepoint is not supported https://github.com/pingcap/tidb/issues/6840"
  end

  def create_savepoint(name = current_savepoint_name)
    raise NotImplementedError, "Savepoint is not supported https://github.com/pingcap/tidb/issues/6840"
  end

  def exec_rollback_to_savepoint(name = current_savepoint_name)
    raise NotImplementedError, "Savepoint is not supported https://github.com/pingcap/tidb/issues/6840"
  end

  def release_savepoint(name = current_savepoint_name)
    raise NotImplementedError, "Savepoint is not supported https://github.com/pingcap/tidb/issues/6840"
  end
end
