class RemoveScoreFromFlickrStream < ActiveRecord::Migration

  def self.up
    remove_column :flickr_streams, :score
  end

  def self.down
    add_column :flickr_streams, :score, :float
  end

end