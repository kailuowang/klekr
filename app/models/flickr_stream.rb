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

      define_method(:get_pictures_from_flickr) do |number_of_pics = 10, since = nil|
        opts = {user_id: user_id, extras: 'date_upload, owner_name', per_page: number_of_pics }
        opts[related_time_field] = since.to_i if since
        flickr_module.send(get_photo_method, opts)
      end

      define_method(:sync) do
        synced = 0
        get_pictures_from_flickr(100, last_sync).each do |pic_info|
          picture = Picture.create_from_pic_info(pic_info)
          picture.save!
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