class AddCollectedToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :collected, :boolean
    Picture.update_all(collected: true)
  end
end
