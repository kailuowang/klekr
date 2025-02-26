class AddDescriptionToPictures < ActiveRecord::Migration[7.1]
  def change
    add_column :pictures, :description, :text
  end
end
