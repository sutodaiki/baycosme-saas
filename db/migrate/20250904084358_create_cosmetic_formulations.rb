class CreateCosmeticFormulations < ActiveRecord::Migration[6.0]
  def change
    create_table :cosmetic_formulations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :product_type
      t.string :skin_type
      t.text :concerns
      t.string :target_age
      t.text :formulation
      t.text :ai_response

      t.timestamps
    end
  end
end
