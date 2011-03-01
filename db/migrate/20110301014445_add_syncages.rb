class AddSyncages < ActiveRecord::Migration
  def self.up
    create_table :syncages do |t|
      t.integer :picture_id
      t.integer :flickr_stream_id

      t.timestamps
    end
  end

  def self.down
    drop_table :syncages
  end

end
