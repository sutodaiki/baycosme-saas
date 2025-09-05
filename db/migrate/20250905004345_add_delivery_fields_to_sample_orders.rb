class AddDeliveryFieldsToSampleOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :sample_orders, :delivery_postal_code, :string
    add_column :sample_orders, :delivery_prefecture, :string
    add_column :sample_orders, :delivery_city, :string
    add_column :sample_orders, :delivery_street, :string
    add_column :sample_orders, :delivery_building, :string
    add_column :sample_orders, :use_company_address, :boolean, default: true
  end
end
