require 'active_record/connection_adapters/abstract/transaction'

ActiveRecord::ConnectionAdapters::Transaction.class_eval do
  
  def materialize!
    #TODO: NOOP
  end

  def materialized?
    #TODO: FIXIT
    false
  end
end
