class AddUrlIndexToPictures < ActiveRecord::Migration
  def self.up
    add_index :pictures, :date_upload
    add_index :pictures, :url

  end

  def self.down
    remove_index :pictures, :date_upload
    remove_index :pictures, :url

  end
end
