class AddSampleIdToSampleOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :sample_orders, :sample, null: true, foreign_key: true
  end
end
