class FlickrStream < ActiveRecord::Base
#  extend Collectr::FlickrSyncor

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

    def sync_uses(flickr_module, get_photo_method, related_time_field)
      define_method(:sync) do
        opts = {user_id: user_id, extras: 'date_upload', related_time_field => last_sync.to_i}
        synced = 0
        flickr_module.send(get_photo_method, opts).each do |pic_info|
          picture = Picture.create_from_pic_info(pic_info)
          Syncage.find_or_create(picture_id: picture.id, flickr_stream_id: id)
          synced += 1
        end
        update_attribute(:last_sync, DateTime.now)
        synced
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
      all.inject(0) {|total_synced, stream| total_synced + stream.sync }
    end
  end


  def user
    @user ||= FlickrStream.get_user_from_flickr(user_id)
  end

  def to_s
    username + "'s " + type
  end

end