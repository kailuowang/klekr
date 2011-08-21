class Collector < ActiveRecord::Base
  has_many :flickr_streams
  has_many :pictures

  def self.find_or_create_by_auth(auth)
    user = auth.user
    user_id = user.nsid
    existing_collector = find_by_user_id(user_id)
    existing_collector ? existing_collector :
            create(user_id: user_id, auth_token: auth.token, user_name: user.username, full_name: user.fullname)
  end


  def collection(per_page, page, filters = {})
    min_rating = filters[:min_rating].to_i
    min_rating = 1 if min_rating == 0
    pictures_in_db = Picture.faved_by(self, min_rating , page, per_page)
    if(pictures_in_db.size == per_page || min_rating > 1)
      pictures_in_db
    else
      pictures_in_db.to_a + get_picture_from_flickr(per_page, pictures_in_db)
    end
  end

  private
  def fave_stream
    @fave_stream ||= FlickrStream.build_type(user_id: self.user_id,
                                             username: self.user_name,
                                             user_url: 'N/A',
                                             collector: self,
                                             type: 'FaveStream')
  end


  def get_picture_from_flickr(per_page, pictures_in_db)

    pictures = fave_stream.get_pictures(per_page - pictures_in_db.size, 1, nil, earlest_faved)
    pictures.each do |pic|
      pic.update_attributes(
        faved_at: Time.at(pic.pic_info.date_faved.to_i).to_datetime,
        rating: 1,
        collected: true
      )
    end
  end

  def earlest_faved
    earlest_fave = Picture.faved.collected_by(self).order('faved_at ASC').where('faved_at IS NOT NULL').first
    earlest_fave ? earlest_fave.faved_at : DateTime.now
  end
end