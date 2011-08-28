class Collector < ActiveRecord::Base
  extend Collectr::FindOrCreate
  include Collectr::FlickrIcon

  has_many :flickr_streams
  has_many :pictures

  def self.create_default_stream(collector)
    stream = FlickrStream.create_type(
            user_id: Settings.default_stream_userid,
            collector: collector,
            type: FaveStream.name
    )
    stream.sync(1.month.ago, 40)
  end

  def self.from_new_user(auth)
    user = auth.user
    user_id = user.nsid
    collector = create(user_id: user_id, auth_token: auth.token, user_name: user.username, full_name: user.fullname)
    if Settings.default_stream_userid
      create_default_stream(collector)
    end
    collector
  end

  def self.find_or_create_by_auth(auth)
    find_by_user_id(auth.user.nsid) || from_new_user(auth)
  end

  def collection(per_page, page, filters = {})
    min_rating = filters[:min_rating].to_i
    min_rating = 1 if min_rating == 0
    pictures_in_db = Picture.faved_by(self, min_rating , page, per_page)
    if(pictures_in_db.size == per_page || min_rating > 1)
      pictures_in_db
    else
      pictures_in_db.to_a + Collectr::FaveImporter.new(self, earlest_faved_in_db).import(per_page - pictures_in_db.size)
    end
  end

  private
  def earlest_faved_in_db
    earlest_fave = Picture.faved.collected_by(self).order('faved_at ASC').where('faved_at IS NOT NULL').first
    earlest_fave ? earlest_fave.faved_at : DateTime.now
  end

end