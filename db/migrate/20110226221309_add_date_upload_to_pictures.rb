class AddDateUploadToPictures < ActiveRecord::Migration[7.1]
  def up
    add_column :pictures, :date_upload, :datetime
  end

  def down
    remove_column :pictures, :date_upload
  end
end
