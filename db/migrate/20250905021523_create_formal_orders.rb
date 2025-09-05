class CreateFormalOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :formal_orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: true, foreign_key: true
      t.references :cosmetic_formulation, null: true, foreign_key: true
      t.references :sample, null: true, foreign_key: true
      t.integer :quantity
      t.integer :status
      t.integer :priority
      t.string :contact_name
      t.string :contact_phone
      t.text :delivery_address
      t.string :delivery_postal_code
      t.string :delivery_prefecture
      t.string :delivery_city
      t.string :delivery_street
      t.string :delivery_building
      t.boolean :use_company_address
      t.text :notes
      t.decimal :shipping_cost
      t.decimal :manufacturing_cost
      t.decimal :unit_price
      t.decimal :total_cost
      t.date :estimated_delivery_date
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.string :tracking_number

      t.timestamps
    end
  end
end
