class RemoveIndustryFromCompanies < ActiveRecord::Migration[6.0]
  def change
    remove_column :companies, :industry, :string
  end
end
