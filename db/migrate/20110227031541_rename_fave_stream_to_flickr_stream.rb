class RenameFaveStreamToFlickrStream < ActiveRecord::Migration
  def self.up
    rename_table 'flickr_streams', 'flickr_streams'
    add_column :flickr_streams, :type, :string
  end

  def self.down
    remove_column :flickr_streams, :type
    rename_table 'flickr_streams', 'flickr_streams'
  end
end
