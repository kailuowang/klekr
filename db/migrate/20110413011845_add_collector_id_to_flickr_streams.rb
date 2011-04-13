class AddCollectorIdToFlickrStreams < ActiveRecord::Migration
  def self.up
    add_column :flickr_streams, :collector_id, :integer
    add_index :flickr_streams, :collector_id
  end

  def self.down
    remove_index :flickr_streams, :collector_id
    remove_column :flickr_streams, :collector_id
  end
end
