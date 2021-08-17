# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :tidb_table, force: true do |t|
    t.string :name
  end

  recreate_sequence :orders_seq, start: 1000
  create_table :tidb_orders, force: true, id: false do |t|
    t.primary_key :id, null: false, default: -> { 'nextval(orders_seq)' }
    t.string :name
  end
end
