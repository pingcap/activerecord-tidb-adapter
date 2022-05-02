require 'active_record/connection_adapters/abstract/savepoints'

ActiveRecord::ConnectionAdapters::Savepoints.class_eval do
  
  def current_savepoint_name
    current_transaction.savepoint_name
  end

  def create_savepoint(name = current_savepoint_name)
    # It should `raise NotImplementedError, "No savepoint support"`` 
    # but let this method NO-OP intentionally. 
    # let release_savepoint or exec_rollback_to_savepoint method raise
    # NotImplementedError
  end

  def exec_rollback_to_savepoint(name = current_savepoint_name)
    raise NotImplementedError, "No savepoint support"
  end

  def release_savepoint(name = current_savepoint_name)
    raise NotImplementedError, "No savepoint support"
  end
end
