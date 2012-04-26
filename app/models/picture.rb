class Picture < ActiveRecord::Base
  include Collectr::Flickr
  scope :desc, order('stream_rating DESC, date_upload DESC')
  scope :asc, order('stream_rating ASC, date_upload ASC')
  scope :old, lambda { |num_of_days| where('updated_at < ?', num_of_days.days.ago)}
  scope :after, lambda { |pic| where('date_upload > ?', pic.date_upload) }
  scope :before, lambda { |pic| where('date_upload <= ? and id <> ? ', pic.date_upload, pic.id) }
  scope :collected_by, lambda { |collector| where(collector_id: collector) if collector }
  scope :unfaved, where(rating:  0)
  scope :valid, where(:no_longer_valid => nil)
  scope :faved, where('rating > 0')
  scope :unviewed, where(viewed: false)
  scope :viewed, where(viewed: true)
  scope :syned_from, lambda { |stream| joins(:syncages).where(syncages: {flickr_stream_id: stream.id}) }
  serialize :pic_info_dump
  has_many :syncages, :dependent => :delete_all
  has_many :flickr_streams, through: :syncages
  belongs_to :collector

  class << self

    def is_flickr_id?(string_id)
      string_id.to_s.include?('_')
    end

    def flickr_id(pic_info)
      pic_info.id + "_" + pic_info.secret
    end

    def reset_stream_ratings
      unviewed.each(&:reset_stream_rating)
    end

    def faved_by(collector, opts, page, per_page)
      scope = faved.collected_by(collector).includes(:flickr_streams, :collector)
      order = opts[:order] || 'faved_at DESC'
      scope = scope.order( order + ', date_upload DESC')
      scope = scope.where('rating >= ?', opts[:min_rating]) if opts[:min_rating]
      scope = scope.where('faved_at <= ?', opts[:max_faved_at]) if opts[:max_faved_at]
      scope = scope.where('faved_at >= ?', opts[:min_faved_at]) if opts[:min_faved_at]
      if Rails.env.production?
        scope = scope.from("`pictures` USE INDEX (index_faved_pictures)")
      end

      scope.paginate(page: page, per_page: per_page, total_entries: per_page * (page + 1) )
    end
  end

  def string_id
    id.try(:to_s) || flickr_id
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

  def resync
    new_secret =
      begin
        flickr.photos.getInfo(photo_id: pic_info.id).secret
      rescue FlickRaw::FailedResponse
        mark_as_invalid
        nil
      end
    update_secret(new_secret) if new_secret.present?
  end

  def fave(new_rating = 1)
    if (old_rating = rating) != new_rating
      update_attributes(rating: new_rating)
      newly_faved if old_rating == 0
    end
  end

  def owner_id
    pic_info.owner.is_a?(String) ? pic_info.owner : pic_info.owner['nsid']
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
    begin
      @pic_info ||= FlickRaw::Response.new *pic_info_dump
    rescue
      Rails.logger.error("Picture #{self.id} failed to dehydrate pic_info")
      Rails.logger.error(pic_info_dump)
      mark_as_invalid
      nil
    end
  end

  def pic_info= pi
    self.title = pi.title
    self.date_upload = get_upload_date(pi)
    self.owner_name = pi['ownername'] || pi['owner']['username']
    self.pic_info_dump = pi.marshal_dump
    @pic_info = pi
  end

  def display_title
    if no_longer_valid?
      'THIS PICTURE WAS REMOVED.'
    elsif title.blank? || ['-', '~', '_', '.'].include?(title)
      "Untitled"
    else
      title
    end
  end

  def get_upload_date(pic_info)
    rawdate = pic_info['dateupload'] || pic_info['dateuploaded']
    Time.at(rawdate.to_i).to_datetime
  end

  def flickr_url size
    if(no_longer_valid? || pic_info.blank?)
      if size == :small
        '/assets/photo_unavailable_s.gif'
      else
        '/assets/photo_unavailable_m.gif'
      end
    else
      case size
        when :large
          FlickRaw.url_b(pic_info)
        when :medium
          FlickRaw.url_z(pic_info) + "?zz=1"
        when :medium_small
          FlickRaw.url(pic_info)
        when :small
          FlickRaw.url_m(pic_info)
        else
          raise "unknown size #{size}"
      end
    end
  end

  def mark_as_invalid
    update_attributes(no_longer_valid: true)
  end


  def large_url
    flickr_url(:large)
  end

  def medium_url
    flickr_url(:medium)
  end

  def medium_small_url
    flickr_url(:medium_small)
  end

  def small_url
    flickr_url(:small)
  end

  def synced_by(stream)
    new_stream_rating = stream.star_rating + (stream_rating || 0)
    self.stream_rating = new_stream_rating
    begin
      save!
      syncages.create(flickr_stream_id: stream.id)
    rescue ArgumentError => e
      Rails.logger.error(e.to_s + e.backtrace.join("\n"))
    end
    self
  end

  def flickr_id
    Picture.flickr_id(pic_info)
  end

  private

  def newly_faved
    update_attribute(:faved_at, DateTime.now )
    flickr_streams.each { |stream| stream.add_score(created_at) }
    if Settings.fave_on_flickr
      try_flickr('Failed to fave picture') do
        flickr.favorites.add(photo_id: pic_info.id)
      end
    end
  end

  def update_secret(new_secret)
    if (new_secret != pic_info.secret)
      pic_info.to_hash['secret'] = new_secret
      self.pic_info = pic_info
      save!
    end
  end
end
