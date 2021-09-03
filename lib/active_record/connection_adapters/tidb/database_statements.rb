require 'active_record/connection_adapters/abstract/database_statements'

ActiveRecord::ConnectionAdapters::DatabaseStatements.class_eval do 
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

  def transaction_isolation_levels
    {
      read_committed: 'READ COMMITTED',
      repeatable_read: 'REPEATABLE READ'
     }
   end
end
