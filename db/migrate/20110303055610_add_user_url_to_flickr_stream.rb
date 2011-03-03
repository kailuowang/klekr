class AddUserUrlToFlickrStream < ActiveRecord::Migration
  def self.up
    add_column :flickr_streams, :user_url, :string
  end

  def self.down
    remove_column :flickr_streams, :user_url
  end
end
