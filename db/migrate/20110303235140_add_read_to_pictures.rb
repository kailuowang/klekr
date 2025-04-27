class AddReadToPictures < ActiveRecord::Migration[7.1]
  def up
    add_column :pictures, :viewed, :boolean, :default => false
  end

  def down
    remove_column :pictures, :viewed
  end
end
