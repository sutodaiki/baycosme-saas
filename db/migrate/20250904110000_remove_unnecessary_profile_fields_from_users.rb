class RemoveUnnecessaryProfileFieldsFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :age, :integer
    remove_column :users, :skin_type, :string
    remove_column :users, :preferred_products, :text
    remove_column :users, :bio, :text
    remove_column :users, :avatar_url, :string
  end
end