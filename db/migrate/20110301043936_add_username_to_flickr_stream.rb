class AddUsernameToFlickrStream < ActiveRecord::Migration[7.1]
  def up
    add_column :flickr_streams, :username, :string
  end

  def down
    remove_column :flickr_streams, :username
  end
end
