class Picture < ActiveRecord::Base
  scope :desc, order('date_upload DESC')
  scope :asc, order('date_upload ASC')

  def self.create_from_pic_info(pic_info)
    picture =  Picture.find_or_create_by_secret(pic_info.secret)
    picture.update_attributes!(
        url: FlickRaw.url_z(pic_info),
        ref_url: FlickRaw.url_photopage(pic_info),
        title: pic_info.title,
        date_upload: Time.at(pic_info.dateupload.to_i).to_datetime
     )
  end

  def previous
    Picture.where('date_upload < ?', date_upload).desc.first
  end

  def next
    Picture.where('date_upload > ?', date_upload).asc.first
  end
end
