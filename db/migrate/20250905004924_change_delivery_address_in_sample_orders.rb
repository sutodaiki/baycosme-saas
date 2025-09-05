class ChangeDeliveryAddressInSampleOrders < ActiveRecord::Migration[6.0]
  def change
    change_column_null :sample_orders, :delivery_address, true
    change_column_null :sample_orders, :contact_name, true
    change_column_null :sample_orders, :contact_phone, true
  end
end
