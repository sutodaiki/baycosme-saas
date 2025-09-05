# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_09_05_021523) do

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.text "address"
    t.string "phone"
    t.string "website"
    t.integer "employee_count"
    t.string "plan", default: "basic", null: false
    t.string "status", default: "active", null: false
    t.integer "created_by"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "postal_code"
    t.index ["created_by"], name: "index_companies_on_created_by"
    t.index ["name"], name: "index_companies_on_name"
    t.index ["status"], name: "index_companies_on_status"
  end

  create_table "cosmetic_formulations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "product_type"
    t.string "skin_type"
    t.text "concerns"
    t.string "target_age"
    t.text "formulation"
    t.text "ai_response"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_cosmetic_formulations_on_user_id"
  end

  create_table "formal_orders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "company_id"
    t.integer "cosmetic_formulation_id"
    t.integer "sample_id"
    t.integer "quantity"
    t.integer "status"
    t.integer "priority"
    t.string "contact_name"
    t.string "contact_phone"
    t.text "delivery_address"
    t.string "delivery_postal_code"
    t.string "delivery_prefecture"
    t.string "delivery_city"
    t.string "delivery_street"
    t.string "delivery_building"
    t.boolean "use_company_address"
    t.text "notes"
    t.decimal "shipping_cost"
    t.decimal "manufacturing_cost"
    t.decimal "unit_price"
    t.decimal "total_cost"
    t.date "estimated_delivery_date"
    t.datetime "shipped_at"
    t.datetime "delivered_at"
    t.string "tracking_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_formal_orders_on_company_id"
    t.index ["cosmetic_formulation_id"], name: "index_formal_orders_on_cosmetic_formulation_id"
    t.index ["sample_id"], name: "index_formal_orders_on_sample_id"
    t.index ["user_id"], name: "index_formal_orders_on_user_id"
  end

  create_table "sample_orders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "company_id"
    t.integer "cosmetic_formulation_id"
    t.integer "quantity", default: 1, null: false
    t.string "status", default: "pending", null: false
    t.string "priority", default: "normal", null: false
    t.text "delivery_address"
    t.string "contact_name"
    t.string "contact_phone"
    t.text "notes"
    t.datetime "shipped_at"
    t.datetime "delivered_at"
    t.string "tracking_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "sample_id"
    t.string "delivery_postal_code"
    t.string "delivery_prefecture"
    t.string "delivery_city"
    t.string "delivery_street"
    t.string "delivery_building"
    t.boolean "use_company_address", default: true
    t.index ["company_id"], name: "index_sample_orders_on_company_id"
    t.index ["cosmetic_formulation_id"], name: "index_sample_orders_on_cosmetic_formulation_id"
    t.index ["created_at"], name: "index_sample_orders_on_created_at"
    t.index ["priority"], name: "index_sample_orders_on_priority"
    t.index ["sample_id"], name: "index_sample_orders_on_sample_id"
    t.index ["status"], name: "index_sample_orders_on_status"
    t.index ["user_id"], name: "index_sample_orders_on_user_id"
  end

  create_table "samples", force: :cascade do |t|
    t.string "name", null: false
    t.string "product_type"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.string "status", default: "available"
    t.string "image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_type"], name: "index_samples_on_product_type"
    t.index ["status"], name: "index_samples_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.integer "company_id"
    t.string "role", default: "member", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "cosmetic_formulations", "users"
  add_foreign_key "formal_orders", "companies"
  add_foreign_key "formal_orders", "cosmetic_formulations"
  add_foreign_key "formal_orders", "samples"
  add_foreign_key "formal_orders", "users"
  add_foreign_key "sample_orders", "companies"
  add_foreign_key "sample_orders", "cosmetic_formulations"
  add_foreign_key "sample_orders", "samples"
  add_foreign_key "sample_orders", "users"
  add_foreign_key "users", "companies"
end
