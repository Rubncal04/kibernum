class CreateActivityLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :activity_logs do |t|
      t.string :scope_type, null: false
      t.integer :scope_id, null: false
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.jsonb :changes_data, null: false, default: {}

      t.timestamps
    end

    add_index :activity_logs, [:scope_type, :scope_id]
    add_index :activity_logs, :action
    add_index :activity_logs, :created_at
    add_index :activity_logs, [:user_id, :created_at]
  end
end
