class Picture < ActiveRecord::Base
  default_scope order('date_upload DESC')
  def self.create_from_pic_info(pic_info)
    picture =  Picture.find_or_create_by_secret(pic_info.secret)
    picture.update_attributes!(
        url: FlickRaw.url_b(pic_info),
        ref_url: FlickRaw.url_photopage(pic_info),
        title: pic_info.title,
        date_upload: pic_info.dateupload
     )
  end
end
