class AddCollectorIdToFlickrStreams < ActiveRecord::Migration[7.1]
  def up
    add_column :flickr_streams, :collector_id, :integer
    add_index :flickr_streams, :collector_id
  end

  def down
    remove_index :flickr_streams, :collector_id
    remove_column :flickr_streams, :collector_id
  end
end
