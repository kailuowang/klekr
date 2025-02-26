class AddUrlIndexToPictures < ActiveRecord::Migration[7.1]
  def up
    add_index :pictures, :date_upload
    add_index :pictures, :url

  end

  def down
    remove_index :pictures, :date_upload
    remove_index :pictures, :url

  end
end
