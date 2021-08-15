# frozen_string_literal: true

module ActiveRecord
  module Sequence
    module ModelMethods
      def nextval(name)
        name = connection.quote_column_name(name)
        connection.query_value("SELECT nextval(#{name})")
      end

      def lastval(name)
        name = connection.quote_column_name(name)
        connection.query_value("SELECT lastval(#{name})")
      end

      def setval(name, value)
        name = connection.quote_column_name(name)
        connection.query_value("SELECT setval(#{name}, #{value})")
      end
    end
  end
end
