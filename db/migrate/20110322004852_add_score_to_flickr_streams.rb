class AddScoreToFlickrStreams < ActiveRecord::Migration[7.1]
  def up
    add_column :flickr_streams, :score, :float
  end

  def down
    remove_column :flickr_streams, :score
  end
end
