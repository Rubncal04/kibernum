class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :address

      t.timestamps
    end
    
    add_index :customers, :email, unique: true
    add_index :customers, :name
  end
end
