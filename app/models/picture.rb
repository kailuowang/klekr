class Picture < ActiveRecord::Base
  include Collectr::Flickr
  scope :desc, order('stream_rating DESC, date_upload DESC')
  scope :asc, order('stream_rating ASC, date_upload ASC')
  scope :old, lambda { |num_of_days| where('updated_at < ?', num_of_days.days.ago)}
  scope :after, lambda { |pic| where('date_upload > ?', pic.date_upload) }
  scope :before, lambda { |pic| where('date_upload <= ? and id <> ? ', pic.date_upload, pic.id) }
  scope :new_pictures, lambda { |n| desc.unviewed.limit(n) }
  scope :collected_by, lambda { |collector| where(collector_id: collector, collected: true) if collector }
  scope :unfaved, where(rating:  0)
  scope :faved, where('rating > 0')
  scope :unviewed, where(viewed: false)
  scope :viewed, where(viewed: true)
  scope :syned_from, lambda { |stream| joins(:syncages).where(syncages: {flickr_stream_id: stream.id}) }
  serialize :pic_info_dump
  has_many :syncages, :dependent => :delete_all
  has_many :flickr_streams, through: :syncages
  belongs_to :collector

  class << self

    def find_or_initialize_from_pic_info(pic_info, collector = nil)
      url = FlickRaw.url_photopage(pic_info)
      Picture.where(collector_id: collector, url: url).first ||
        Picture.new.tap do |picture|
          picture.url = url
          picture.title = pic_info.title
          picture.date_upload = Time.at(pic_info.dateupload.to_i).to_datetime
          picture.owner_name = pic_info.ownername
          picture.pic_info_dump = pic_info.marshal_dump
          picture.collector = collector
          picture.collected = false
        end
    end

    def create_from_sync(pic_info, stream)
      picture = Picture.find_or_initialize_from_pic_info(pic_info, stream.collector)
      new_picture = picture.new_record?
      already_synced = !new_picture && Syncage.where(flickr_stream_id: stream.id, picture_id: picture.id).present?
      picture.synced_by(stream) unless already_synced
      return picture, !already_synced
    end

    def reset_stream_ratings
      unviewed.each(&:reset_stream_rating)
    end

    def most_interesting_for(collector)
      desc.collected_by(collector).unviewed.first
    end

    def new_pictures_by(collector, n, *exclude_ids)
      scope = collected_by(collector).new_pictures(n).includes(:flickr_streams)
      pictures = Picture.arel_table
      scope = scope.where(pictures[:id].not_in(exclude_ids)) if exclude_ids.present?
      scope
    end

    def faved_by(collector, page, per_page)
      collected_by(collector).where('rating > ?', 0).order('faved_at DESC, updated_at DESC').paginate(page: page, per_page: per_page )
    end
  end

  def string_id
    id || url.hash
  end

  def reset_stream_rating
    total_rating = flickr_streams.inject(0) { |sum, stream| sum + stream.star_rating }
    update_attribute(:stream_rating, total_rating)
  end

  def get_viewed
    unless viewed?
      update_attribute(:viewed, true)
      flickr_streams.each(&:picture_viewed)
    end
    self
  end

  def fave(new_rating = 1)
    if (old_rating = rating) != new_rating
      update_attribute(:rating, new_rating)
      newly_faved if old_rating == 0
    end
  end

  def unfave
    if faved?
      update_attribute(:rating, 0)
      try_flickr('Failed to remove from fave picture') do
        flickr.favorites.remove(photo_id: pic_info.id)
      end
    end
  end

  def faved?
    rating > 0
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

  def guess_hidden_treasure
    Picture.syned_from(FlickrStream.least_viewed).desc.unviewed.limit(1)[0]
  end

  def synced_by(stream)
    new_stream_rating = stream.star_rating + (stream_rating || 0)
    self.stream_rating = new_stream_rating
    self.collected = true if stream.collecting?
    save!
    syncages.create(flickr_stream_id: stream.id)
    self
  end

  private

  def newly_faved
    update_attribute(:faved_at, DateTime.now )
    flickr_streams.each { |stream| stream.add_score(created_at) }
    try_flickr('Failed to fave picture') do
      flickr.favorites.add(photo_id: pic_info.id)
    end
  end

end
