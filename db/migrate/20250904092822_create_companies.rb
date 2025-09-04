class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.text :address
      t.string :phone
      t.string :website
      t.string :industry
      t.integer :employee_count
      t.string :plan, default: 'basic', null: false
      t.string :status, default: 'active', null: false
      t.integer :created_by, null: false

      t.timestamps
    end
    
    add_index :companies, :name
    add_index :companies, :status
    add_index :companies, :created_by
  end
end
