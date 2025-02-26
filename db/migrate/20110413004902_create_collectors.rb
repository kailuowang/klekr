class CreateCollectors < ActiveRecord::Migration[7.1]
  def up
    create_table :collectors do |t|
      t.string :user_id
      t.string :user_name
      t.string :full_name
      t.string :auth_token
      t.timestamps
    end
    add_index :collectors, :user_id, :unique => true
  end

  def down
    remove_index :collectors, :user_id
    drop_table :collectors
  end
end
