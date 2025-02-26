class AddCollectedToPictures < ActiveRecord::Migration[7.1]
  def change
    add_column :pictures, :collected, :boolean
    Picture.update_all(collected: true)
  end
end
