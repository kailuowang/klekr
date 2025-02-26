class AddUserUrlToFlickrStream < ActiveRecord::Migration[7.1]
  def up
    add_column :flickr_streams, :user_url, :string
  end

  def down
    remove_column :flickr_streams, :user_url
  end
end
