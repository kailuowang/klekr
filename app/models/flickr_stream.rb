class FlickrStream < ActiveRecord::Base
  extend Collectr::FlickrSyncor

  TYPES = [:fave, :upload]

  validates_uniqueness_of :user_id, :scope => :type
  validates_presence_of :user_id

  class << self
    def build(params)
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
  end

  def user
    flickr.people.getInfo(user_id: user_id)
  end

  def sync
    sync_pictures_from_flickr
    update_attribute(:last_sync, DateTime.now)
  end
end