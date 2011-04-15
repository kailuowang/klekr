class CreateCollectors < ActiveRecord::Migration
  def self.up
    create_table :collectors do |t|
      t.string :user_id
      t.string :user_name
      t.string :full_name
      t.string :auth_token
      t.timestamps
    end
    add_index :collectors, :user_id, :unique => true
  end

  def self.down
    remove_index :collectors, :user_id
    drop_table :collectors
  end
end
