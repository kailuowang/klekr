class AddPictureFlickrStreamIdIndexToSyncages < ActiveRecord::Migration
  def change
    add_index :syncages, :picture_id
    add_index :syncages, :flickr_stream_id
  end
end
