class RenameFaveStreamToFlickrStream < ActiveRecord::Migration
  def self.up
    rename_table 'fave_streams', 'flickr_streams'
    add_column :flickr_streams, :type, :string
  end

  def self.down
    remove_column :flickr_streams, :type
    rename_table 'flickr_streams', 'fave_streams'
  end
end
