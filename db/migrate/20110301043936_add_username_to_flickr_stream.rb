class AddUsernameToFlickrStream < ActiveRecord::Migration
  def self.up
    add_column :flickr_streams, :username, :string
  end

  def self.down
    remove_column :flickr_streams, :username
  end
end
