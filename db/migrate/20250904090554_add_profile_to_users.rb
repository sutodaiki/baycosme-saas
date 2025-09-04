class AddProfileToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string
    add_column :users, :age, :integer
    add_column :users, :skin_type, :string
    add_column :users, :preferred_products, :text
    add_column :users, :bio, :text
    add_column :users, :avatar_url, :string
  end
end
