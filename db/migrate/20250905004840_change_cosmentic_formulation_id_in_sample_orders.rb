class ChangeCosmenticFormulationIdInSampleOrders < ActiveRecord::Migration[6.0]
  def change
    change_column_null :sample_orders, :cosmetic_formulation_id, true
    change_column_null :sample_orders, :company_id, true
  end
end
