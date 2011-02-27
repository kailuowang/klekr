class AddDateUploadToPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :date_upload, :datetime
  end

  def self.down
    remove_column :pictures, :date_upload
  end
end
