class CreateProductImages < ActiveRecord::Migration[8.0]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true
      t.string :image_url, null: false
      t.string :alt_text
      t.boolean :is_primary, default: false, null: false
      t.integer :order_index, default: 0, null: false

      t.timestamps
    end
    
    add_index :product_images, [:product_id, :order_index]
    add_index :product_images, [:product_id, :is_primary]
  end
end
