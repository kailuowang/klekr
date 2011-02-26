require 'flickraw'
class FaveStream < ActiveRecord::Base

  def sync
    flickr.favorites.getList(user_id: user_id, extra: 'date_upload').each do |pic_info|
      Picture.create_from_pic_info(pic_info)
    end
  end

end
