class RemoveUserUrlFromFlickrStream < ActiveRecord::Migration
  def change
    remove_column :flickr_streams, :user_url
  end
end
