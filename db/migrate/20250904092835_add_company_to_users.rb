class AddCompanyToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :company, null: true, foreign_key: true
    add_column :users, :role, :string, default: 'member', null: false
    
    add_index :users, :role
  end
end
