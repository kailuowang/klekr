class Picture < ActiveRecord::Base
  scope :desc, order('date_upload DESC')
  scope :asc, order('date_upload ASC')
  serialize :pic_info_dump
  has_many :syncages
  has_many :flickr_streams, through: :syncages



  def self.create_from_pic_info(pic_info)
    url = FlickRaw.url_photopage(pic_info)
    picture =  Picture.find_or_create_by_url(url)
    picture.update_attributes!(
        title: pic_info.title,
        date_upload: Time.at(pic_info.dateupload.to_i).to_datetime,
        pic_info_dump: pic_info.marshal_dump )
    picture
  end


  def previous
    Picture.where('date_upload < ?', date_upload).desc.first
  end

  def previous_pictures(n)
    n > 0 && previous ? [previous] + previous.previous_pictures(n-1) : []
  end

  def next
    Picture.where('date_upload > ?', date_upload).asc.first
  end

  def pic_info
    @pic_info ||= FlickRaw::Response.new *pic_info_dump
  end


  def flickr_url size
    case size
      when :large
        FlickRaw.url_b(pic_info)
      when :medium
        FlickRaw.url_z(pic_info)
      else
        raise "unknown size #{size}"
    end
  end

  def large_url
    flickr_url(:large)
  end

  def medium_url
    flickr_url(:medium)
  end
end
