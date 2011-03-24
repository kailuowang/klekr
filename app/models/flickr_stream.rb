class FlickrStream < ActiveRecord::Base

  TYPES = ['FaveStream', 'UploadStream']

  validates_uniqueness_of :user_id, :scope => :type
  validates_presence_of :user_id

  has_many :syncages
  has_many :pictures, through: :syncages
  has_many :monthly_scores

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

  def sync
    photos_synced = 0
    get_pic_up_to_last_sync.each do |pic_info|
      Picture.create_from_sync(pic_info, self)
      photos_synced += 1
    end
    update_attribute(:last_sync, DateTime.now)
    score_for(Date.today).add_num_of_pics(photos_synced)
    photos_synced
  end

  def add_score(source_date)
    score_for(source_date).add 1
  end


  def user
    @user ||= FlickrStream.get_user_from_flickr(user_id)
  end

  def to_s
    username + "'s " + type
  end

  def rating
    return 0 if monthly_scores.blank?
    total_weighted_monthly_rating = monthly_scores.inject(0) { |wr, ms| wr + ms.weighted_rating }
    total_weight = monthly_scores.inject(0) { |w, ms| w + ms.weight }
    total_weighted_monthly_rating / total_weight
  end

  private

  def get_pic_up_to_last_sync(page = 1)
    result =  get_pictures_from_flickr(100, last_sync || 1.month.ago, page).to_a
    result += get_pic_up_to_last_sync(page + 1) unless result.empty?
    result
  end

  def score_for(date)
    MonthlyScore.by_month_stream(date, self).first ||
      monthly_scores.create!(month: date.month, year: date.year)
  end

end