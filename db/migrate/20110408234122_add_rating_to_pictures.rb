class AddRatingToPictures < ActiveRecord::Migration[7.1]
  def up
    add_column :pictures, :rating, :integer, default: 0
  end

  def down
    remove_column :pictures, :rating
  end
end
