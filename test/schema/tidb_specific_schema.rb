ActiveRecord::Schema.define do
  create_table :tidb_table, force: true do |t|
    t.string :name
  end
end
