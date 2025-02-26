class AddStreamRatingIndexToPictures < ActiveRecord::Migration[7.1]
  def up
    add_index :pictures, :stream_rating
  end

  def down
    remove_index :pictures, :stream_rating
  end
end
