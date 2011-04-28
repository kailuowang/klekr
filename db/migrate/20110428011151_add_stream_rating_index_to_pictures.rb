class AddStreamRatingIndexToPictures < ActiveRecord::Migration
  def self.up
    add_index :pictures, :stream_rating
  end

  def self.down
    remove_index :pictures, :stream_rating
  end
end
