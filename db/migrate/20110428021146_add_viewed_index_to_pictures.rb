class AddViewedIndexToPictures < ActiveRecord::Migration[7.1]
  def up
    add_index :pictures, :viewed
  end

  def down
    remove_index :pictures, :viewed
  end
end
