class FlickrStream < ActiveRecord::Base

  TYPES = ['FaveStream', 'UploadStream']
  PER_PAGE = 20

  validates_uniqueness_of :user_id, :scope => :type
  validates_presence_of :user_id

  has_many :syncages
  has_many :pictures, through: :syncages
  has_many :monthly_scores, order: 'year desc, month desc'
  cattr_reader :per_page
  @@per_page = 30

  class << self
    def build(params)
      params = params.to_options
      unless params[:username] && params[:user_url]
        user = get_user_from_flickr(params[:user_id])
        params[:username] = user.username
        params[:user_url] = user.photosurl
      end
      params[:type].constantize.new(params)
    end

    def inherited(child)
      child.instance_eval do
        def model_name
          FlickrStream.model_name
        end
      end
      super
    end

    def get_user_from_flickr user_id
      flickr.people.getInfo(user_id: user_id)
    end

    def sync_all
      all.inject(0) {|total_synced, stream| total_synced + stream.sync }
    end

    def import(data)
      count = 0
      data.map(&:to_options).each do |entry|
        unless where(user_id: entry[:user_id], type: entry[:type]).count > 0
          build(entry).save!
          count += 1
        end
      end
      count
    end

    protected
    def sync_uses(flickr_module, get_photo_method, related_time_field)
      define_method(:get_pictures_from_flickr) do |per_page = 10, since = nil, page_number = 1|
        opts = {user_id: user_id, extras: 'date_upload, owner_name', per_page: per_page }
        opts[related_time_field] = since.to_i if since
        opts[:page] = page_number if page_number > 1
        begin
          flickr_module.send(get_photo_method, opts)
        rescue FlickRaw::FailedResponse => e
          Rails.logger.error("failed sync photo from flickr" + e.code.to_s + "\n" + e.msg)
          []
        end
      end
    end
  end

  def sync(up_to = last_sync || 1.month.ago, max_num = nil)
    photos_synced = 0
    get_pic_up_to(up_to, max_num).each do |pic_info|
      newly_synced = Picture.create_from_sync(pic_info, self)
      photos_synced += 1 if newly_synced
    end
    update_attribute(:last_sync, DateTime.now)
    score_for(Date.today).add_num_of_pics(photos_synced)
    photos_synced
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

  def user
    @user ||= FlickrStream.get_user_from_flickr(user_id)
  end

  def to_s
    username + "'s " + type
  end


  def rating
    @rating ||= calculate_rating()
  end

  def score_for(date)
    MonthlyScore.by_month_stream(date, self).first ||
      monthly_scores.create!(month: date.month, year: date.year)
  end

  def num_of_pics_this_month
    MonthlyScore.by_month_stream(Date.today, self).first.try(:num_of_pics).to_i
  end



  private

  def calculate_rating
    return 0 if monthly_scores.blank?
    total_weighted_monthly_rating = monthly_scores.inject(0) { |wr, ms| wr + ms.weighted_rating }

    total_weight = monthly_scores.inject(0) { |w, ms| w + ms.weight }

    total_weighted_monthly_rating / total_weight
  end

  def adjust_rating adjustment
    monthly_scores[0..1].each(&adjustment)
  end

  def get_pic_up_to(up_to, max = nil, page = 1 )
    up_to = nil unless max.nil?
    result =  get_pictures_from_flickr(PER_PAGE, up_to, page).to_a
    retrieved_max_num_of_pics = max && PER_PAGE * page >= max
    unless(retrieved_max_num_of_pics || result.empty?)
      result += get_pic_up_to(up_to,  max, page + 1)
    end
    result
  end


end