class AddViewedIndexToPictures < ActiveRecord::Migration
  def self.up
    add_index :pictures, :viewed
  end

  def self.down
    remove_index :pictures, :viewed
  end
end
