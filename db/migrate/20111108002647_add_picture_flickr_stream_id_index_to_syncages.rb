class AddPictureFlickrStreamIdIndexToSyncages < ActiveRecord::Migration[7.1]
  def change
    # Index for picture_id already exists from AddSyncages migration
    add_index :syncages, :flickr_stream_id unless index_exists?(:syncages, :flickr_stream_id)
  end
end
