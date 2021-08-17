# frozen_string_literal: true

module ActiveRecord
  module Sequence
    module Adapter
      def check_sequences
        select_all(
          'SELECT * FROM information_schema.sequences ORDER BY sequence_name'
        ).to_a
      end

      def create_sequence(name, options = {})
        increment = options[:increment] || options[:step]
        name = quote_column_name(name)

        sql = ["CREATE SEQUENCE IF NOT EXISTS #{name}"]
        sql << "INCREMENT BY #{increment}" if increment
        sql << "START WITH #{options[:start]}" if options[:start]
        sql << if options[:cache]
                 "CACHE #{options[:cache]}"
               else
                 'NOCACHE'
               end

        sql << if options[:cycle]
                 'CYCLE'
               else
                 'NOCYCLE'
               end

        sql << "MIN_VALUE #{options[:min_value]}" if options[:min_value]

        sql << "COMMENT #{quote(options[:comment].to_s)}" if options[:comment]

        execute(sql.join("\n"))
      end

      def drop_sequence(name)
        name = quote_column_name(name)
        sql = "DROP SEQUENCE IF EXISTS #{name}"
        execute(sql)
      end

      def recreate_sequence(name, options = {})
        drop_sequence(name)
        create_sequence(name, options)
      end
    end
  end
end
