class Collector < ActiveRecord::Base
  extend Collectr::FindOrCreate
  include Collectr::FlickrIcon

  has_many :flickr_streams
  has_many :pictures
  scope :report, order: 'last_login asc'
  def self.from_new_user(auth)
    user = auth.user
    user_id = user.nsid
    create(user_id: user_id, auth_token: auth.token, user_name: user.username, full_name: user.fullname)
  end

  def self.find_or_create_by_auth(auth)
    find_by_user_id(auth.user.nsid) || from_new_user(auth)
  end

  def collection(per_page, page, filters = {})

    pictures_in_db = Picture.faved_by(self, collection_conditions(filters) , page, per_page)
    if(pictures_in_db.size == per_page || filters.present?)
      pictures_in_db
    else
      pictures_in_db.to_a + import_from_flickr(per_page - pictures_in_db.size)
    end
  end

  def import_from_flickr(num)
    Collectr::FaveImporter.new(self, earlest_faved_in_db - 5).import(num)
  end

  def import_all_from_flickr
    unless self.collection_synced?
      per_page = 200
      done = false
      until done
        imported_num = import_from_flickr(per_page).size
        Rails.logger.info("#{imported_num} fave pictures imported for #{self.user_name}")
        done = imported_num < per_page
      end
      update_attributes(collection_synced: true)
    end
  end

  private

  def collection_conditions(filter_params)
    {}.tap do |h|
      h[:min_rating] = filter_params[:min_rating].to_i if filter_params[:min_rating].present?
      if( filter_params[:faved_date].present? )
        date = Date.strptime(filter_params[:faved_date], '%m/%d/%Y')
        h[:max_faved_at] = date + 1 if date
      end
    end
  end
  def earlest_faved_in_db
    earlest_fave = Picture.faved.collected_by(self).order('faved_at ASC').where('faved_at IS NOT NULL').first
    earlest_fave ? earlest_fave.faved_at : DateTime.now
  end

end