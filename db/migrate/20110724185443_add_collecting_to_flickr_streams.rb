class AddCollectingToFlickrStreams < ActiveRecord::Migration[7.1]
  def change
    add_column :flickr_streams, :collecting, :boolean, :default => true
  end
end
