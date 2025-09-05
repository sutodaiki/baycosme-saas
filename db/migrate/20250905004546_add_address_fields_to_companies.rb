class AddAddressFieldsToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :postal_code, :string unless column_exists?(:companies, :postal_code)
    add_column :companies, :address, :string unless column_exists?(:companies, :address)
  end
end
