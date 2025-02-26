class RemoveScoreFromFlickrStream < ActiveRecord::Migration[7.1]

  def up
    remove_column :flickr_streams, :score
  end

  def down
    add_column :flickr_streams, :score, :float
  end

end