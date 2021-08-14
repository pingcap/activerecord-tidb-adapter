# frozen_string_literal: true

module ActiveRecord
  module Sequence
    module CommandRecorder
      def create_sequence(name, options = {})
        record(__method__, [name, options])
      end

      def drop_sequence(name)
        record(__method__, [name])
      end

      def invert_create_sequence(args)
        name, = args
        [:drop_sequence, [name]]
      end
    end
  end
end
