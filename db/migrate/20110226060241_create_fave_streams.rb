class CreateFaveStreams < ActiveRecord::Migration
  def self.up
    create_table :fave_streams do |t|
      t.string :user_id
      t.datetime :last_sync

      t.timestamps
    end
  end

  def self.down
    drop_table :fave_streams
  end
end
