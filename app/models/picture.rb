class Picture < ActiveRecord::Base
  def self.create_from_pic_info(pic_info)
     Picture.create!(
        url: FlickRaw.url_b(pic_info),
        ref_url: FlickRaw.url(pic_info),
        secret: pic_info.secret,
        title: pic_info.title,
        date_upload: pic_info.dateupload
     )
  end
end
