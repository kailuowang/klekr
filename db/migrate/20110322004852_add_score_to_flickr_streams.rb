class AddScoreToFlickrStreams < ActiveRecord::Migration
  def self.up
    add_column :flickr_streams, :score, :float
  end

  def self.down
    remove_column :flickr_streams, :score
  end
end
