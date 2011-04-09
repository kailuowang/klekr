class AddRatingToPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :rating, :integer, default: 0
  end

  def self.down
    remove_column :pictures, :rating
  end
end
