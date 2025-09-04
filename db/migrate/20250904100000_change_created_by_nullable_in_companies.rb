class ChangeCreatedByNullableInCompanies < ActiveRecord::Migration[6.0]
  def change
    change_column_null :companies, :created_by, true
  end
end