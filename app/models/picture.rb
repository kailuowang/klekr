class Picture < ActiveRecord::Base
  scope :desc, order('date_upload DESC')
  scope :asc, order('date_upload ASC')
  serialize :pic_info_dump

  def self.create_from_pic_info(pic_info)
    url = FlickRaw.url_photopage(pic_info)
    picture =  Picture.find_or_create_by_url(url)
    picture.update_attributes!(
        title: pic_info.title,
        date_upload: Time.at(pic_info.dateupload.to_i).to_datetime,
        pic_info_dump: pic_info.marshal_dump
     )
  end

  def previous
    Picture.where('date_upload < ?', date_upload).desc.first
  end

  def next
    Picture.where('date_upload > ?', date_upload).asc.first
  end

  def pic_info
    @pic_info ||= FlickRaw::Response.new *pic_info_dump
  end

  def medium_url
    FlickRaw.url_z(pic_info)
  end
end
