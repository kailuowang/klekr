class ReplaceSecretAndRefUrlWithPicInfoToPictures < ActiveRecord::Migration
  def self.up
    remove_column :pictures, :secret
    remove_column :pictures, :ref_url
    add_column :pictures, :pic_info_dump, :text
  end

  def self.down
    remove_column :pictures, :pic_info_dump
    add_column :pictures, :secret, :string
    add_column :pictures, :ref_url, :string
  end
end
