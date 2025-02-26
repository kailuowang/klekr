class RenameFaveStreamToFlickrStream < ActiveRecord::Migration[7.1]
  def up
    rename_table 'fave_streams', 'flickr_streams'
    add_column :flickr_streams, :type, :string
  end

  def down
    remove_column :flickr_streams, :type
    rename_table 'flickr_streams', 'fave_streams'
  end
end
