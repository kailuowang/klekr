require 'flickraw'
class FaveStream < ActiveRecord::Base

  def sync
    flickr.favorites.getList(:user_id => user_id).each do |pic|
      Picture.find_or_create_by_secret(pic.secret)
    end
  end

end
