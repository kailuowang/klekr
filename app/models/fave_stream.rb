require 'flickraw'
class FaveStream < ActiveRecord::Base

  def sync
    flickr.favorites.getList(user_id: user_id, extras: 'date_upload').each do |pic_info|
      Rails.logger.info(pic_info.methods - Object.methods)
      Picture.create_from_pic_info(pic_info)
    end
  end

end
