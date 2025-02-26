class FlickrStream < ActiveRecord::Base
  include Collectr::Flickr
  include Collectr::FlickrIcon
  extend Collectr::Flickr


  TYPES = ['FaveStream', 'UploadStream'].freeze
  DEFAULT_TYPE = 'UploadStream'

  validates_uniqueness_of :user_id, :scope => [:collector_id, :type]
  validates_presence_of :user_id
  belongs_to :collector

  scope :collecting, -> { where(collecting: true) }
  scope :collected_by, ->(collector) { collecting.where(collector_id: collector) if collector }
  scope :of_user, ->(user_id) { where(user_id: user_id) }
  scope :type, ->(type) { where(type: type) }
  scope :old, ->(num_of_days) { where('updated_at < ?', num_of_days.days.ago) }
  scope :active_in, ->(num_of_days) { joins(:collector).where('collectors.last_login > ?', num_of_days.days.ago) }
  scope :unsynced_after, ->(before) { where('last_sync < ? or last_sync is null', before) }
  has_many :syncages, dependent: :delete_all
  # Restoring the original association to fix issues
  has_many :pictures, through: :syncages
  has_many :monthly_scores, -> { order('year desc, month desc') }

  cattr_reader :per_page
  @@per_page = 30

  class << self
    def create_type(params)
      params = params.with_indifferent_access
      # Ensure a collector is provided or create a basic one
      params[:collector] ||= Collector.first_or_create!(user_id: 'default', user_name: 'default')
      
      stream = build_type(params)
      stream.save!
      stream
    end

    def build_type(params)
      params = params.with_indifferent_access
      unless params[:username].present? || params[:type] == 'GroupStream'
        user = get_user_from_flickr(params[:user_id], params[:collector])
        params[:username] = user.username
      end
      params[:type].constantize.new(params.except(:type))
    end

    def find_or_create(params)
      stream = params[:collector].flickr_streams.type(params[:type]).of_user(params[:user_id]).includes(:monthly_scores).first
      if(stream)
        stream.update(params.except(:type, :collector))
        stream
      else
        create_type(params)
      end
    end

    def inherited(child)
      child.instance_eval do
        def model_name
          FlickrStream.model_name
        end
      end
      super
    end

    def get_user_from_flickr user_id, collector
      begin
        # Using the flickr-objects API to get user info
        if collector&.access_token
          client = configure_flickr_client(collector.access_token, collector.access_secret)
          client.people.find(user_id)
        else
          # Fall back to the global client for non-authenticated requests
          Collectr::FLICKR_CLIENT.people.find(user_id)
        end
      rescue StandardError => e
        Rails.logger.error("failed to load user info from flickr (userid #{user_id}): #{e.message}")
        # Create a simple mock user for development/testing
        OpenStruct.new(
          username: "user_#{user_id}", 
          name: "User #{user_id}",
          real_name: "User #{user_id}",
          id: user_id,
          path_alias: "user_#{user_id}",
          icon_url: "https://www.flickr.com/buddyicons/#{user_id}.jpg"
        )
      end
    end

    def sync_all(opts = {})
      opts.reverse_merge!({collector: nil, verbose: false, synced_before: Time.now})
      collector, verbose, time_range = opts[:collector], opts[:verbose], opts[:synced_before]

      streams_to_sync = get_streams_to_sync(time_range, collector)
      
      stream_count = streams_to_sync.count
      
      results = {total_streams_synced: 0, total_pictures_synced: 0, total_streams_to_sync: stream_count}

      puts "Start to sync all streams #{Time.now.strftime("%H:%M")} " if verbose
      streams_to_sync.each do |stream|
        begin
          synced = stream.sync(stream.last_sync, 200, verbose) if stream.collecting?
          results[:total_streams_synced] += 1 if synced
          results[:total_pictures_synced] += synced.to_i
        rescue => e
          title = "failed to sync flickr stream(id: #{stream.id}) due to flickr server error (#{e.to_s})"
          Rails.logger.error(title)
          # Avoid sending emails in development
          AdminMailer.error_report(e, title) if Rails.env.production?
        end
      end
      
      num_collectors = streams_to_sync.map(&:collector).uniq.size
      puts "Finished syncing all #{streams_to_sync.size} streams with #{results[:total_pictures_synced]} pictures for #{num_collectors} collectors #{Time.now.strftime("%H:%M")}" if verbose
      results
    end

    def get_streams_to_sync(time_range, collector)
      collector_scope = collector ? collected_by(collector) : active_in(30)
      collector_scope.collecting.unsynced_after(time_range)
    end

    def import(data, collector)
      count = 0
      data.map(&:to_options).each do |entry|
        unless of_user(entry[:user_id]).where(collector_id: collector).type(entry[:type]).count > 0
          create_type(entry.merge(collector_id: collector.id))
          count += 1
        end
      end
      count
    end

    def least_viewed(collector = nil)
      unviewed(collector) || get_least_viewed(collector)
    end

    def unviewed(collector = nil)
      # Add a more comprehensive query to find streams with unviewed pictures
      query = collected_by(collector).joins(:syncages, :pictures)
        .where(pictures: {viewed: false})
        .group("flickr_streams.id")
        .limit(1)
        .first
        
      # Fallback to streams with no monthly scores but with syncages
      query || collected_by(collector).where("not exists (select * from monthly_scores where flickr_stream_id = flickr_streams.id) and exists (select * from syncages where flickr_stream_id = flickr_streams.id)").limit(1).first
    end

    protected
    def sync_uses(opts)
      define_method(:flickr_picture_retriever) do
        @flickr_picture_retriever ||= Collectr::FlickrPictureRetriever.new(opts.merge(
                                                              user_id: user_id,
                                                              collector: collector)
                                                            )
      end
    end

    private
    def get_least_viewed(collector)
      scope = MonthlyScore.select('monthly_scores.flickr_stream_id, sum(num_of_pics) as pics_viewed').
              where(%{ exists ( SELECT * FROM pictures INNER JOIN syncages ON pictures.id = syncages.picture_id WHERE syncages.flickr_stream_id = monthly_scores.flickr_stream_id and pictures.viewed = 'f' ) }).
              group('monthly_scores.flickr_stream_id').
              order('pics_viewed ASC').
              limit(1)
      scope = scope.joins(:flickr_stream).where(flickr_streams: {collector_id: collector}) if collector
      result = scope[0]
      return nil unless result
      FlickrStream.find(result.flickr_stream_id)
    end
  end

  def alternative_stream
    @alternative_stream ||= FlickrStream.find_or_create(user_id: user_id, collector: collector, type: alternative_type)
  end

  def flickr_picture_retriever
    @flickr_picture_retriever ||= Collectr::FlickrPictureRetriever.new(
      module: :favorites, 
      method: :getList, 
      time_field: :fave_date, 
      user_id: user_id, 
      collector: collector
    )
  end
  
  def get_pictures(num, page = 1, since = nil, before = nil )
    # Try using FlickrRetriever first for more reliable results
    begin
      Rails.logger.info("Getting pictures using FlickrRetriever for stream #{id} (#{type})")
      
      # Use the appropriate retriever method based on stream type
      if self.is_a?(FaveStream)
        retriever = Collectr::FlickrRetriever.new(collector)
        pic_infos = retriever.get_favorites(user_id, {per_page: num, page: page})
      elsif self.is_a?(UploadStream)
        retriever = Collectr::FlickrRetriever.new(collector)
        pic_infos = retriever.get_public_photos(user_id, {per_page: num, page: page})
      else
        # Fall back to original method for other types
        pic_infos = flickr_picture_retriever.get(num, page, since, before)
      end
      
      if pic_infos.present?
        Rails.logger.info("Got #{pic_infos.size} pictures from FlickrRetriever")
        
        # Debug log the first photo's critical fields
        if pic_infos.first.is_a?(Hash)
          first_pic = pic_infos.first
          Rails.logger.debug("Sample photo fields: " + {
            id: first_pic['id'],
            secret: first_pic['secret'],
            server: first_pic['server'],
            farm: first_pic['farm'],
            url_s: first_pic['url_s'],
            url_m: first_pic['url_m']
          }.inspect)
        end
        
        # Use batch processing to efficiently create/find picture objects
        return picture_repo.build_batch(pic_infos)
      else
        Rails.logger.warn("No photos returned from FlickrRetriever, trying original method")
      end
    rescue => e
      Rails.logger.error("Error using FlickrRetriever: #{e.message}")
    end
    
    # Fall back to original method if FlickrRetriever failed
    Rails.logger.info("Falling back to original picture retriever method")
    pic_infos = flickr_picture_retriever.get(num, page, since, before)
    
    # Log sample to help debug
    if pic_infos.present? && pic_infos.first.respond_to?(:to_hash) 
      Rails.logger.debug("Sample from FlickrPictureRetriever: #{pic_infos.first.to_hash.slice('id', 'secret', 'server', 'farm', 'url_s', 'url_m')}")
    elsif pic_infos.present? && pic_infos.first.is_a?(Hash)
      Rails.logger.debug("Sample from FlickrPictureRetriever: #{pic_infos.first.slice('id', 'secret', 'server', 'farm', 'url_s', 'url_m')}")
    else
      Rails.logger.warn("No pictures or invalid format from FlickrPictureRetriever")
    end
    
    # Use batch processing to efficiently create/find picture objects
    pictures = picture_repo.build_batch(pic_infos)
    
    # Log the number of pictures successfully built
    Rails.logger.info("Built #{pictures.size} pictures from #{pic_infos.size} picture infos")
    
    pictures
  end

  def user_url
    "http://www.flickr.com/photos/#{user_id}/"
  end

  def subscribe
    update_attribute(:collecting, true)
  end

  def unsubscribe
    update_attribute(:collecting, false)
    mark_all_as_read
  end

  def set_as_synced
    update_attribute(:last_sync, DateTime.now)
  end

  def synced_with?(picture)
    Syncage.where(flickr_stream_id: id, picture_id: picture.id).present?
  end

  def sync(since = nil, max_num = Collectr::FlickrPictureRetriever.flickr_photos_per_page / 4, verbose = false)
    begin
      since ||= last_sync || 1.month.ago
      photos_synced = 0
      
      # Get photos using the retriever (only 2 pages max by default)
      max_pages = 2
      per_page = Collectr::FlickrPictureRetriever.flickr_photos_per_page / 2
      
      Rails.logger.info("Syncing stream #{id} (#{username}): Getting up to #{max_pages} pages with #{per_page} photos per page")
      
      # Get first page
      pic_infos = flickr_picture_retriever.get(per_page, 1, since)
      
      # Get second page if needed and if first page had results
      if pic_infos.present? && pic_infos.length == per_page
        Rails.logger.info("Getting second page for sync")
        second_page = flickr_picture_retriever.get(per_page, 2, since)
        pic_infos += second_page if second_page.present?
      end
      
      Rails.logger.info("Retrieved total of #{pic_infos.size} pictures for sync")
      
      # Process pictures in batches of 50 for efficiency
      pic_infos.each_slice(50) do |batch|
        # Create pictures with batch processing
        picture_repo.build_batch(batch).each do |picture|
          begin
            # Check if the picture is already synchronized with this stream
            already_synced = !picture.new_record? && synced_with?(picture)
            
            # Synchronize the picture if not already done
            unless already_synced
              picture.synced_by(self)
              photos_synced += 1
            end
          rescue => e
            Rails.logger.error("Error creating picture from sync: #{e.message}")
          end
        end
      end
      
      # Update sync timestamp regardless of success
      update_attribute(:last_sync, DateTime.now)
      print "." if verbose && photos_synced > 0
      photos_synced
    rescue => e
      Rails.logger.error("Error in sync for stream #{id} (#{username}): #{e.message}")
      update_attribute(:last_sync, DateTime.now) # Still update to prevent repeated failures
      0 # Return 0 pictures synced on error
    end
  end

  def picture_viewed
    score_for(Date.today).add_num_of_pics_viewed
  end

  def add_score(source_date, to_add = 1)
    score_for(source_date).add(to_add)
  end

  def bump_rating(to = star_rating + 1)
    if(to <= 5 )
      while(star_rating < to) do
        adjust_rating(:bump)
      end
    end
  end

  def trash_rating
    if(star_rating > 1)
      adjust_rating(:trash)
    end
  end

  def destroy
    pictures.includes(:syncages).each do |pic|
      pic.destroy unless pic.syncages.size > 1
    end
    super
  end

  def star_rating
    if rating < 0.01
      1
    elsif rating < 0.05
      2
    elsif rating < 0.12
      3
    elsif rating < 0.2
      4
    else
      5
    end
  end

  def user
    # Cache the user info to avoid frequent API calls
    @user ||= begin
      # Try to get user info from Flickr
      FlickrStream.get_user_from_flickr(user_id, collector)
    rescue => e
      # If Flickr API fails, use a dummy user object
      Rails.logger.error("Error fetching user data: #{e.message}")
      OpenStruct.new(
        username: username || "user_#{user_id}", 
        name: username || "User #{user_id}"
      )
    end
  end

  def to_s
    (username || user.try(:username) || "Unknown User") + "'s " + self.type_display
  end

  def rating
    @rating ||= calculate_rating()
  end

  def score_for(date)
    MonthlyScore.by_month_stream(date, self).first ||
      monthly_scores.create!(month: date.month, year: date.year)
  end

  def mark_all_as_read
    pictures.unviewed.update_all(viewed: true)
  end

  private

  def calculate_rating

    return 0 if monthly_scores.blank?

    total_weighted_monthly_rating = 0

    monthly_scores.each { |ms|
      total_weighted_monthly_rating += ms.weighted_rating
    }

    total_weight = monthly_scores.inject(0) { |w, ms| w + ms.weight }

    total_weighted_monthly_rating / total_weight
  end

  def adjust_rating adjustment
    old_rating = star_rating
    score_for(Date.today)
    while(star_rating == old_rating)
      @rating = nil
      monthly_scores.each(&adjustment)
    end
  end

  def alternative_type
    rest = FlickrStream::TYPES.dup
    rest.delete(self.type)
    rest.first
  end

  def picture_repo
    @picture_repo ||= Collectr::PictureRepo.new(self.collector)
  end

end