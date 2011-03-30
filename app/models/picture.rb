class Picture < ActiveRecord::Base
  scope :desc, order('stream_rating DESC, date_upload DESC')
  scope :asc, order('stream_rating ASC, date_upload ASC')
  scope :after, lambda {|pic| where('date_upload > ?', pic.date_upload)}
  scope :before, lambda {|pic| where('date_upload < ?', pic.date_upload)}
  scope :unviewed, where(viewed: false)

  serialize :pic_info_dump
  has_many :syncages
  has_many :flickr_streams, through: :syncages



  def self.find_or_initialize_from_pic_info(pic_info)
    url = FlickRaw.url_photopage(pic_info)
    picture =  Picture.find_by_url(url) || Picture.new
    picture.url = url
    picture.title = pic_info.title
    picture.date_upload = Time.at(pic_info.dateupload.to_i).to_datetime
    picture.owner_name = pic_info.ownername
    picture.pic_info_dump = pic_info.marshal_dump
    picture
  end



  def self.create_from_sync(pic_info, stream)
    picture = Picture.find_or_initialize_from_pic_info(pic_info)
    picture.save!
    picture.synced_by(stream)
  end

  def self.reset_stream_ratings
    unviewed.each(&:reset_stream_rating)
  end

  def reset_stream_rating
    total_rating = flickr_streams.inject(0){|sum, stream| sum + stream.star_rating}
    update_attribute(:stream_rating, total_rating)
  end

  def get_viewed
    unless viewed?
      update_attribute(:viewed, true)
      flickr_streams.each(&:picture_viewed)
    end
  end

  def synced_by(stream)
    synced =  syncages.find( :first, conditions: { flickr_stream_id: stream.id } ).present?
    unless synced
      syncages.create( flickr_stream_id: stream.id )
      update_attribute( :stream_rating, stream.star_rating + (stream_rating || 0 ) )
    end

    !synced
  end

  def next_new_pictures(n)
     Picture.desc.unviewed.limit(n)
  end

  def next
    Picture.after(self).asc.first
  end

  def fave
    begin
      flickr.favorites.add(photo_id: pic_info.id)
    rescue FlickRaw::FailedResponse
    end
    flickr_streams.each {|stream| stream.add_score(created_at, 0.3) }
  end

  def pic_info
    @pic_info ||= FlickRaw::Response.new *pic_info_dump
  end


  def flickr_url size
    case size
      when :large
        FlickRaw.url_b(pic_info)
      when :medium
        FlickRaw.url_z(pic_info) + "?zz=1"
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
