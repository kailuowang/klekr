class Picture < ActiveRecord::Base
  scope :desc, order('date_upload DESC')
  scope :asc, order('date_upload ASC')
  scope :after, lambda {|pic| where('date_upload > ?', pic.date_upload)}
  scope :before, lambda {|pic| where('date_upload < ?', pic.date_upload)}
  scope :unviewed, where(viewed: false)

  serialize :pic_info_dump
  has_many :syncages
  has_many :flickr_streams, through: :syncages



  def self.create_from_pic_info(pic_info)
    url = FlickRaw.url_photopage(pic_info)
    picture =  Picture.find_by_url(url) || Picture.new
    picture.url = url
    picture.title = pic_info.title
    picture.date_upload = Time.at(pic_info.dateupload.to_i).to_datetime
    picture.owner_name = pic_info.ownername
    picture.pic_info_dump = pic_info.marshal_dump
    picture
  end


  def previous
    Picture.before(self).desc.first
  end

  def next_new_pictures(n)
     Picture.desc.before(self).unviewed.limit(n)
  end

  def next
    Picture.after(self).asc.first
  end

  def fave
    flickr.favorites.add(photo_id: pic_info.id)
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
      when :small
        FlickRaw.url_m(pic_info)
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

  def small_url
    flickr_url(:small)
  end
end
