class CreateSamples < ActiveRecord::Migration[6.0]
  def change
    create_table :samples do |t|
      t.string :name, null: false
      t.string :product_type
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.string :status, default: 'available'
      t.string :image_url
      t.timestamps
      
      t.index :product_type
      t.index :status
    end
  end
end
