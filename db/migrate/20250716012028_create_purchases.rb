class CreatePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.datetime :purchase_date, null: false

      t.timestamps
    end
    
    add_index :purchases, :purchase_date
    add_index :purchases, [:customer_id, :purchase_date]
    add_index :purchases, [:product_id, :purchase_date]
  end
end
