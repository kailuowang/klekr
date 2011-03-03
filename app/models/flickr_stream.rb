class FlickrStream < ActiveRecord::Base
  extend Collectr::FlickrSyncor

  TYPES = [:fave, :upload]

  validates_uniqueness_of :user_id, :scope => :type
  validates_presence_of :user_id

  has_many :syncages

  class << self
    def build(params)
      user = get_user_from_flickr(params[:user_id])
      params[:username] = user.username
      params[:user_url] = user.photosurl
      case params['type']
        when 'fave'
          FaveStream.new(params)
        when 'upload'
          UploadStream.new(params)
        else
          raise "unknown Stream type #{params['type']}"
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

    def get_user_from_flickr user_id
      flickr.people.getInfo(user_id: user_id)
    end

    def sync_all
      all.each {|stream| stream.sync}
    end
  end

  def user
    @user ||= FlickrStream.get_user_from_flickr(user_id)
  end


  def sync
    sync_pictures_from_flickr(self)
    update_attribute(:last_sync, DateTime.now)
  end
end