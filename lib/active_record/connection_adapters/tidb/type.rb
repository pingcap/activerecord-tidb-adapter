# frozen_string_literal: true

module ActiveRecord
  module Type
    class << self
      def adapter_name_from(_model)
        :mysql
      end
    end
  end
end
