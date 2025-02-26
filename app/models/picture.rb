class Picture < ActiveRecord::Base
  include Collectr::Flickr
  scope :desc, -> { order('stream_rating DESC, date_upload DESC') }
  scope :asc, -> { order('stream_rating ASC, date_upload ASC') }
  scope :old, ->(num_of_days) { where('updated_at < ?', num_of_days.days.ago) }
  scope :after, ->(pic) { where('date_upload > ?', pic.date_upload) }
  scope :before, ->(pic) { where('date_upload <= ? and id <> ? ', pic.date_upload, pic.id) }
  scope :collected_by, ->(collector) { where(collector_id: collector) if collector }
  scope :unfaved, -> { where(rating: 0) }
  scope :valid, -> { where(no_longer_valid: nil) }
  scope :faved, -> { where('rating > 0') }
  scope :unviewed, -> { where(viewed: false) }
  scope :viewed, -> { where(viewed: true) }
  scope :syned_from, ->(stream) { joins(:syncages).where(syncages: {flickr_stream_id: stream.id}) }
  serialize :pic_info_dump, coder: YAML
  has_many :syncages, dependent: :delete_all
  has_many :flickr_streams, through: :syncages
  belongs_to :collector

  class << self

    def is_flickr_id?(string_id)
      string_id.to_s.include?('_')
    end

    def flickr_id(pic_info)
      if pic_info.is_a?(Hash)
        "#{pic_info['id']}_#{pic_info['secret']}"
      elsif pic_info.respond_to?(:id) && pic_info.respond_to?(:secret)
        "#{pic_info.id}_#{pic_info.secret}"
      else
        # If we can't determine ID, return a timestamp-based ID
        "flickr_#{Time.now.to_i}_#{rand(1000)}"
      end
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
        # Use the global Flickr class from the gem
        ::Flickr.photos.get_info(pic_info.id).secret
      rescue => e
        Rails.logger.error("Failed to get photo info: #{e.message}")
        mark_as_invalid
        nil
      end
    update_secret(new_secret) if new_secret.present?
  end

  def fave(new_rating = 1)
    if (old_rating = rating) != new_rating
      update(rating: new_rating)
      newly_faved if old_rating == 0
    end
  end

  def owner_id
    if pic_info.is_a?(Hash) && pic_info['owner']
      pic_info['owner']
    elsif pic_info.respond_to?(:owner)
      if pic_info.owner.is_a?(String)
        pic_info.owner
      elsif pic_info.owner.respond_to?(:[]) && pic_info.owner['nsid']
        pic_info.owner['nsid']
      else
        pic_info.owner
      end
    elsif pic_info_dump.is_a?(Array) && pic_info_dump.first.is_a?(Hash) && pic_info_dump.first['owner']
      pic_info_dump.first['owner']
    else
      nil
    end
  end
  
  def secret
    if pic_info.respond_to?(:secret)
      pic_info.secret
    elsif pic_info_dump.is_a?(Array) && pic_info_dump.first.is_a?(Hash) && pic_info_dump.first['secret']
      pic_info_dump.first['secret']
    else
      nil
    end
  end

  def unfave
    if faved?
      update_attribute(:rating, 0)
      try_flickr('Failed to remove from fave picture') do
        ::Flickr.photos.remove_from_favorites(pic_info.id)
      end
    end
  end

  def faved?
    rating > 0
  end

  def pic_info
    begin
      return @pic_info if @pic_info
      
      # If pic_info_dump is already a hash, just use it directly
      if pic_info_dump.is_a?(Hash)
        @pic_info = pic_info_dump
      # Fall back to first element if it's an array
      elsif pic_info_dump.is_a?(Array) && pic_info_dump.first.is_a?(Hash)
        @pic_info = pic_info_dump.first
      # Create a simple OpenStruct if it's a complex object
      elsif pic_info_dump.respond_to?(:to_h) || pic_info_dump.respond_to?(:to_hash)
        @pic_info = OpenStruct.new(pic_info_dump.to_hash)
      # Just return the raw data as a last resort
      else
        @pic_info = pic_info_dump
      end
      
      @pic_info
    rescue => e
      Rails.logger.error("Picture #{self.id} failed to dehydrate pic_info: #{e.message}")
      Rails.logger.error(pic_info_dump.inspect)
      mark_as_invalid
      nil
    end
  end

  def pic_info=(pi)
    Rails.logger.debug("Setting pic_info for picture: #{pi.inspect}")
    
    # Ensure we have a Hash for consistency
    pi_hash = if pi.is_a?(Hash)
      pi
    elsif pi.respond_to?(:to_hash)
      pi.to_hash
    elsif pi.respond_to?(:marshal_dump)
      pi.marshal_dump
    else
      { 'error' => 'Unknown picture info format' }
    end
    
    # Set the title
    if pi_hash['title']
      self.title = pi_hash['title']
    elsif pi.respond_to?(:title)
      self.title = pi.title
    else
      self.title = "Untitled"
    end
    
    # Set upload date
    self.date_upload = get_upload_date(pi_hash)
    
    # Set owner name
    self.owner_name = get_owner_name(pi_hash)
    
    # Log pic_info contents - especially important fields for URL generation
    Rails.logger.debug("Picture info fields: " + {
      id: pi_hash['id'],
      secret: pi_hash['secret'],
      server: pi_hash['server'],
      farm: pi_hash['farm'],
      owner: pi_hash['owner']
    }.inspect)
    
    # Store the pic_info
    self.pic_info_dump = pi_hash
    
    # Cache for this instance
    @pic_info = pi_hash
  end
  
  def get_owner_name(pi)
    if pi.is_a?(Hash)
      if pi['ownername']
        pi['ownername']
      elsif pi['owner'] && pi['owner'].is_a?(Hash) && pi['owner']['username']
        pi['owner']['username']
      elsif pi['owner_name']
        pi['owner_name']
      else
        "Unknown"
      end
    elsif pi.respond_to?(:owner_name)
      pi.owner_name
    elsif pi.respond_to?(:owner) && pi.owner.respond_to?(:username)
      pi.owner.username
    else
      "Unknown"
    end
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
    # First check if we have a cached prebuilt URL from Flickr
    direct_url = case size
      when :large
        pic_info.is_a?(Hash) && pic_info['url_b']
      when :medium
        pic_info.is_a?(Hash) && pic_info['url_z']
      when :medium_small
        pic_info.is_a?(Hash) && pic_info['url_m']
      when :small
        pic_info.is_a?(Hash) && pic_info['url_s']
    end
    
    # If we have a direct URL and it's valid, use it
    if direct_url.present? && direct_url.start_with?('http')
      Rails.logger.debug("Using direct URL from pic_info for size #{size}: #{direct_url}")
      return direct_url + (size == :medium ? "?zz=1" : "")
    end
    
    # Otherwise continue with normal URL generation
    if(no_longer_valid? || pic_info.blank?)
      Rails.logger.warn("Using placeholder for #{id || 'new'} (size: #{size}) - no_longer_valid=#{no_longer_valid?}, blank pic_info=#{pic_info.blank?}")
      if size == :small
        '/assets/photo_unavailable_s.gif'
      else
        '/assets/photo_unavailable_m.gif'
      end
    else
      begin
        case size
          when :large
            url_for_size('b')
          when :medium
            url_for_size('z') + "?zz=1"
          when :medium_small
            url_for_size('m')
          when :small
            url_for_size('s')
          else
            raise "unknown size #{size}"
        end
      rescue => e
        Rails.logger.error("Error generating URL for size #{size}: #{e.message}")
        if size == :small
          '/assets/photo_unavailable_s.gif'
        else
          '/assets/photo_unavailable_m.gif'
        end
      end
    end
  end
  
  # Build URL for Flickr photo of the given size
  def url_for_size(size_code)
    # First check if this is a direct API resource or hash with direct URLs
    if pic_info.nil?
      Rails.logger.error("Picture info is nil")
      return '/assets/photo_unavailable_m.gif'
    end
    
    # First try to get pre-generated URLs from the API result
    url_field = case size_code
      when 's' then 'url_s'
      when 'm' then 'url_m'
      when 'sq' then 'url_sq'
      when 'z' then 'url_z'
      when 'b' then 'url_b'
    end
    
    # If URL exists directly in pic_info, use it
    if pic_info.is_a?(Hash) && url_field && pic_info[url_field].present?
      Rails.logger.debug("Using pre-generated URL for size #{size_code}: #{pic_info[url_field]}")
      return pic_info[url_field]
    end
    
    # If this is a direct Flickr API response with a sizes element, try that
    if pic_info.is_a?(Hash) && pic_info['sizes'] && pic_info['sizes']['size'].is_a?(Array)
      size_label = case size_code
        when 's' then 'Small'
        when 'm' then 'Medium'
        when 'sq' then 'Square'
        when 'z' then 'Medium 640'
        when 'b' then 'Large'
      end
      
      if size_label
        size_info = pic_info['sizes']['size'].find { |s| s['label'] == size_label }
        if size_info && size_info['source']
          Rails.logger.debug("Using size element URL for size #{size_code}: #{size_info['source']}")
          return size_info['source']
        end
      end
    end
    
    # Extract required components for building the URL
    if pic_info.respond_to?(:farm) && pic_info.respond_to?(:server) && pic_info.respond_to?(:id) && pic_info.respond_to?(:secret)
      server = pic_info.server
      id = pic_info.id
      secret = pic_info.secret
      farm = pic_info.farm
    elsif pic_info.is_a?(Hash)
      server = pic_info['server']
      id = pic_info['id']
      secret = pic_info['secret']
      farm = pic_info['farm']
    else
      # If we can't find the info, return a placeholder
      Rails.logger.error("Can't generate URL - missing or invalid photo data: #{pic_info.inspect}")
      return '/assets/photo_unavailable_m.gif'
    end
    
    # Check if we have all required parts
    if server.blank? || id.blank? || secret.blank? || farm.blank?
      Rails.logger.error("Missing required fields for URL: server=#{server}, id=#{id}, secret=#{secret}, farm=#{farm}")
      resync if id.present?  # Try to resync if we at least have an ID
      return '/assets/photo_unavailable_m.gif'
    end
    
    # Standard Flickr URL format
    url = "https://farm#{farm}.staticflickr.com/#{server}/#{id}_#{secret}_#{size_code}.jpg"
    Rails.logger.debug("Generated URL for photo #{id}, size #{size_code}: #{url}")
    url
  end

  def mark_as_invalid
    update(no_longer_valid: true)
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
        ::Flickr.photos.add_to_favorites(pic_info.id)
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
