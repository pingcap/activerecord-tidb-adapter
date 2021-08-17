# frozen_string_literal: true

require 'cases/helper_tidb'
require 'models/tidb_order'
require 'pry'

module TiDB
  class SequenceTest < ActiveRecord::TestCase
    self.use_transactional_tests = false

    def setup
      @connection = ActiveRecord::Base.connection
    end

    def tearndown
      ActiveRecord::Base.connection.recreate_sequence(:orders_seq, start: 1000)
    end

    def test_sequence_as_pk
      @order = TidbOrder.create!(name: 'name')
      assert_equal @order.id, 1000
    end
  end
end
