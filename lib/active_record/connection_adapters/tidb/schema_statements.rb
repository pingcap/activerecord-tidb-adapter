require 'pry'
require 'active_record/connection_adapters/mysql/schema_statements'


ActiveRecord::ConnectionAdapters::MySQL::SchemaStatements.class_eval do 
  def new_column_from_field(table_name, field)
    type_metadata = fetch_type_metadata(field[:Type], field[:Extra])
    if type_metadata.type == :datetime && /\ACURRENT_TIMESTAMP(?:\([0-6]?\))?\z/i.match?(field[:Default])
      default, default_function = nil, field[:Default]
    elsif field[:Default].to_s =~ /nextval/i
      default_function = field[:Default]
      default = nil
    else
      default, default_function = field[:Default], nil
    end

    ActiveRecord::ConnectionAdapters::MySQL::Column.new(
      field[:Field],
      default,
      type_metadata,
      field[:Null] == "YES",
      table_name,
      default_function,
      field[:Collation],
      comment: field[:Comment].presence
    )
  end
end