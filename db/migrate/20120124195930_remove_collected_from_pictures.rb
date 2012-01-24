class RemoveCollectedFromPictures < ActiveRecord::Migration
  def up
    remove_column :pictures, :collected
  end

  def down
    add_column :pictures, :collected, :boolean, default: true
  end
end
