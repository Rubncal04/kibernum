# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_16_013000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activity_logs", force: :cascade do |t|
    t.string "scope_type", null: false
    t.integer "scope_id", null: false
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.jsonb "changes_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_activity_logs_on_action"
    t.index ["created_at"], name: "index_activity_logs_on_created_at"
    t.index ["scope_type", "scope_id"], name: "index_activity_logs_on_scope_type_and_scope_id"
    t.index ["user_id", "created_at"], name: "index_activity_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_categories_on_created_by_id"
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "categories_products", id: false, force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "category_id", null: false
    t.index ["category_id", "product_id"], name: "index_categories_products_on_category_id_and_product_id"
    t.index ["product_id", "category_id"], name: "index_categories_products_on_product_id_and_category_id", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["name"], name: "index_customers_on_name"
  end

  create_table "product_images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "image_url", null: false
    t.string "alt_text"
    t.boolean "is_primary", default: false, null: false
    t.integer "order_index", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "is_primary"], name: "index_product_images_on_product_id_and_is_primary"
    t.index ["product_id", "order_index"], name: "index_product_images_on_product_id_and_order_index"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_products_on_created_by_id"
    t.index ["name"], name: "index_products_on_name"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.datetime "purchase_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "purchase_date"], name: "index_purchases_on_customer_id_and_purchase_date"
    t.index ["customer_id"], name: "index_purchases_on_customer_id"
    t.index ["product_id", "purchase_date"], name: "index_purchases_on_product_id_and_purchase_date"
    t.index ["product_id"], name: "index_purchases_on_product_id"
    t.index ["purchase_date"], name: "index_purchases_on_purchase_date"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "activity_logs", "users"
  add_foreign_key "categories", "users", column: "created_by_id"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "users", column: "created_by_id"
  add_foreign_key "purchases", "customers"
  add_foreign_key "purchases", "products"
  add_foreign_key "users", "roles"
end
