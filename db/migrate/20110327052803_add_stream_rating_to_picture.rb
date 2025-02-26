class AddStreamRatingToPicture < ActiveRecord::Migration[7.1]
  def up
    add_column :pictures, :stream_rating, :float
  end

  def down
    remove_column :pictures, :stream_rating
  end
end
