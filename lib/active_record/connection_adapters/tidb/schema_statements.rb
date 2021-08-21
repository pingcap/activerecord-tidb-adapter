require 'active_record/connection_adapters/mysql/schema_statements'

ActiveRecord::ConnectionAdapters::MySQL::SchemaStatements.class_eval do 
  def indexes(table_name)
    indexes = []
    current_index = nil
    execute_and_free("SHOW KEYS FROM #{quote_table_name(table_name)}", "SCHEMA") do |result|
      each_hash(result) do |row|
        if current_index != row[:Key_name]
          next if row[:Key_name] == "PRIMARY" # skip the primary key
          current_index = row[:Key_name]

          mysql_index_type = row[:Index_type].downcase.to_sym
          case mysql_index_type
          when :fulltext, :spatial
            index_type = mysql_index_type
          when :btree, :hash
            index_using = mysql_index_type
          end

          indexes << [
            row[:Table],
            row[:Key_name],
            row[:Non_unique].to_i == 0,
            [],
            lengths: {},
            orders: {},
            type: index_type,
            using: index_using,
            comment: row[:Index_comment].presence
          ]
        end
        
        # FIX https://github.com/pingcap/tidb/issues/26110 for older version of TiDB
        row[:Expression] = nil if row[:Expression] == 'NULL'

        if row[:Expression]
          expression = row[:Expression]
          expression = +"(#{expression})" unless expression.start_with?("(")
          indexes.last[-2] << expression
          indexes.last[-1][:expressions] ||= {}
          indexes.last[-1][:expressions][expression] = expression
          indexes.last[-1][:orders][expression] = :desc if row[:Collation] == "D"
        else
          indexes.last[-2] << row[:Column_name]
          indexes.last[-1][:lengths][row[:Column_name]] = row[:Sub_part].to_i if row[:Sub_part]
          indexes.last[-1][:orders][row[:Column_name]] = :desc if row[:Collation] == "D"
        end
      end
    end

    indexes.map do |index|
      options = index.pop

      if expressions = options.delete(:expressions)
        orders = options.delete(:orders)
        lengths = options.delete(:lengths)

        columns = index[-1].map { |name|
          [ name.to_sym, expressions[name] || +quote_column_name(name) ]
        }.to_h

        index[-1] = add_options_for_index_columns(
          columns, order: orders, length: lengths
        ).values.join(", ")
      end

      ActiveRecord::ConnectionAdapters::IndexDefinition.new(*index, **options)
    end
  end
end