# frozen_string_literal: true

module ActiveRecord
  module Sequence
    module SchemaDumper
      def header(stream)
        super
        sequences(stream)
      end

      def sequences(stream)
        sequences = @connection.check_sequences
        return if sequences.empty?

        sequences.each do |seq|
          start_value = seq['START']
          increment = seq['INCREMENT']
          cache = seq['CACHE']
          cache_value = seq['CACHE_VALUE']
          min_value = seq['MIN_VALUE']
          cycle = seq['CYCLE']
          comment = seq['COMMENT']

          options = []

          options << "start: #{start_value}" if start_value && Integer(start_value) != 1

          options << "increment: #{increment}" if increment && Integer(increment) != 1

          options << "cache: #{cache_value}" if cache_value && Integer(cache_value) != 0

          options << "min_value: #{min_value}" if min_value

          options << 'cycle: true' if cycle.to_i != 0

          options << "comment: #{comment.inspect}" if comment.present?

          statement = [
            'create_sequence',
            seq['SEQUENCE_NAME'].inspect
          ].join(' ')

          if options.any?
            statement << (options.any? ? ", #{options.join(', ')}" : '')
          end

          stream.puts "  #{statement}"
        end

        stream.puts
      end
    end
  end
end
