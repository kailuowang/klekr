class CreateCollectors < ActiveRecord::Migration
  def self.up
    create_table :collectors do |t|
      t.string :user_id
      t.string :auth_token

      t.timestamps
    end
  end

  def self.down
    drop_table :collectors
  end
end
