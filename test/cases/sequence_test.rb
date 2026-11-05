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

    def test_setval
      TidbOrder.setval(:orders_seq, 2000)
      assert_equal 2001, TidbOrder.nextval(:orders_seq)

      TidbOrder.setval(:orders_seq, '3000')
      assert_equal 3001, TidbOrder.nextval(:orders_seq)
    ensure
      @connection.recreate_sequence(:orders_seq, start: 1000)
    end

    def test_setval_rejects_non_integer_value
      assert_raises(ArgumentError) { TidbOrder.setval(:orders_seq, '1) + (SELECT 1') }
      assert_raises(ArgumentError) { TidbOrder.setval(:orders_seq, '1 OR 1=1') }
      assert_raises(TypeError) { TidbOrder.setval(:orders_seq, nil) }
    end
  end
end
