class CreateSampleOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :sample_orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.references :cosmetic_formulation, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.string :status, null: false, default: 'pending'
      t.string :priority, null: false, default: 'normal'
      t.text :delivery_address, null: false
      t.string :contact_name, null: false
      t.string :contact_phone, null: false
      t.text :notes
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.string :tracking_number

      t.timestamps
    end

    add_index :sample_orders, :status
    add_index :sample_orders, :priority
    add_index :sample_orders, :created_at
  end
end
