class RemoveCollectedFromPictures < ActiveRecord::Migration[7.1]
  def up
    remove_column :pictures, :collected
  end

  def down
    add_column :pictures, :collected, :boolean, default: true
  end
end
