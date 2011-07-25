class AddCollectingToFlickrStreams < ActiveRecord::Migration
  def change
    add_column :flickr_streams, :collecting, :boolean, :default => true
  end
end
