class AddStreamRatingToPicture < ActiveRecord::Migration
  def self.up
    add_column :pictures, :stream_rating, :float
  end

  def self.down
    remove_column :pictures, :stream_rating
  end
end
