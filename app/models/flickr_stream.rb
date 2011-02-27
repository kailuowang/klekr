class FlickrStream < ActiveRecord::Base
  extend Collectr::FlickrSyncor

  def user
    flickr.people.getInfo(user_id: user_id)
  end
end