class FlickrStream < ActiveRecord::Base
  include Collectr::Flickr
  extend Collectr::Flickr

  TYPES = ['FaveStream', 'UploadStream'].freeze
  DEFAULT_TYPE = 'UploadStream'
  FLICKR_PHOTOS_PER_PAGE = 20

  validates_uniqueness_of :user_id, :scope => [:collector_id, :type]
  validates_presence_of :user_id
  belongs_to :collector

  scope :collecting, where(collecting: true)
  scope :collected_by, lambda {|collector| collecting.where(collector_id: collector) if collector }
  scope :of_user, lambda {|user_id| where(user_id: user_id)}
  scope :type, lambda { |type| where(type: type) }

  has_many :syncages
  has_many :pictures, through: :syncages
  has_many :monthly_scores, order: 'year desc, month desc'

  cattr_reader :per_page
  @@per_page = 30

  class << self
    def create_type(params)
      params = params.with_indifferent_access
      unless params[:username] && params[:user_url]
        user = get_user_from_flickr(params[:user_id], params[:collector])
        params[:username] = user.username
        params[:user_url] = user.photosurl
      end
      stream = params[:type].constantize.new(params)
      stream.save!
      stream
    end

    def find_or_create(params)
      stream = of_user(params[:user_id]).where(collector_id: params[:collector]).type(params[:type]).first
      stream ||
        create_type(params.merge(collecting: false))
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
      flickr(collector).people.getInfo(user_id: user_id)
    end

    def sync_all(collector = nil)
      streams_to_sync = collector ? collected_by(collector).collecting : collecting

      streams_to_sync.inject(0) {|total_synced, stream| total_synced + stream.sync }
    end

    def import(data, collector)
      count = 0
      data.map(&:to_options).each do |entry|
        unless of_user(entry[:user_id]).collected_by(collector).type(entry[:type]).count > 0
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
      collected_by(collector).where("not exists (select * from monthly_scores where flickr_stream_id = flickr_streams.id) and exists (select * from syncages where flickr_stream_id = flickr_streams.id)").limit(1)[0]
    end

    protected
    def sync_uses(flickr_module, get_photo_method, related_time_field)
      define_method(:retriever) do
        @retriever ||= Collectr::FlickrPictureRetriever.new(module: flickr_module,
                                                            method: get_photo_method,
                                                            time_field: related_time_field,
                                                            user_id: user_id,
                                                            collector: collector)
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
    FlickrStream.find_or_create(user_id: user_id, collector: collector, type: alternative_type)
  end

  def get_pictures(num, page = 1)
    retriever.get(num, page).map do |pic_info|
      pic, _  = Picture.create_from_sync(pic_info, self)
      pic
    end
  end

  def subscribe
    update_attribute(:collecting, true)
  end

  def unsubscribe
    update_attribute(:collecting, false)
  end

  def sync(since = last_sync || 1.month.ago, max_num = nil)
    photos_synced = 0
    retriever.get_all(since, max_num).each do |pic_info|
      _, newly_synced = Picture.create_from_sync(pic_info, self)
      photos_synced += 1 if newly_synced
    end
    update_attribute(:last_sync, DateTime.now)
    photos_synced
  end

  def picture_viewed
    score_for(Date.today).add_num_of_pics_viewed
  end

  def add_score(source_date, to_add = 1)
    score_for(source_date).add(to_add)
  end

  def bump_rating
    adjust_rating(:bump)
  end

  def trash_rating
    adjust_rating(:trash)
  end

  def destroy
    pictures.includes(:syncages).each do |pic|
      pic.destroy unless pic.syncages.size > 1
    end
    super
  end

  def star_rating
    if rating < 0.05
      1
    elsif rating < 0.1
      2
    elsif rating < 0.2
      3
    elsif rating < 0.3
      4
    else
      5
    end
  end

  def user
    @user ||= FlickrStream.get_user_from_flickr(user_id, collector)
  end

  def to_s
    username + "'s " + self.type_display
  end

  def rating
    @rating ||= calculate_rating()
  end

  def score_for(date)
    MonthlyScore.by_month_stream(date, self).first ||
      monthly_scores.create!(month: date.month, year: date.year)
  end

  def mark_all_as_read
    pictures.unviewed.each { |pic| pic.update_attribute(:viewed, true)}
  end

  private

  def calculate_rating

    return 0 if monthly_scores.blank?

    total_weighted_monthly_rating = 0

    monthly_scores.all.each { |ms|
      total_weighted_monthly_rating += ms.weighted_rating
    }

    total_weight = monthly_scores.all.inject(0) { |w, ms| w + ms.weight }

    total_weighted_monthly_rating / total_weight
  end

  def adjust_rating adjustment
    old_rating = star_rating
    score_for(Date.today)
    while(star_rating == old_rating)
      @rating = nil
      monthly_scores.all.each(&adjustment)
    end
  end

  def alternative_type
    rest = FlickrStream::TYPES.dup
    rest.delete(self.type)
    rest.first
  end


end