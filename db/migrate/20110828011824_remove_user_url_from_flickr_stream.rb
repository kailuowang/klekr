class RemoveUserUrlFromFlickrStream < ActiveRecord::Migration[7.1]
  def change
    remove_column :flickr_streams, :user_url
  end
end
