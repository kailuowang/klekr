class Collector < ActiveRecord::Base
  extend Collectr::FindOrCreate
  include Collectr::FlickrIcon

  has_many :flickr_streams
  has_many :pictures
  scope :report, order: 'last_login asc'
  def self.from_new_user(auth)
    puts auth[:user].inspect
    user = auth[:user]
    create(user_id: user['id'],
           access_token: auth[:access_token],
           access_secret: auth[:access_secret],
           user_name: user.username,
           full_name: "")
  end

  def self.find_or_create_by_auth(auth)
    find_by_user_id(auth[:user]['id']) || from_new_user(auth)
  end

  def collection(per_page, page, opts = {})
    pictures_in_db = Picture.faved_by(self, collection_opts(opts), page, per_page)
    if(pictures_in_db.to_a.size == per_page || opts.present?)
      pictures_in_db
    else
      pictures_in_db.to_a + import_from_flickr(per_page - pictures_in_db.size)
    end
  end

  def import_from_flickr(num)
    Collectr::FaveImporter.new(self, earlest_faved_in_db - 5).import(num)
  end

  def import_all_from_flickr(verbose = false)
    unless self.collection_synced?
      per_page = 200
      done = false
      until done
        imported_num = import_from_flickr(per_page).size
        msg = "#{imported_num} fave pictures imported for #{self.user_name}"
        Rails.logger.info(msg)
        puts msg if verbose
        done = imported_num < (per_page / 2)
      end
      update_attributes(collection_synced: true)
    end
  end

  def is_editor?
    Collectr::Editor.new.is_editor self
  end

  private

  def parse_date(date_string)
    Date.strptime(date_string, '%m/%d/%Y') if date_string.present?
  end

  def collection_opts(opts_params)
    opts_params.to_options!
    {}.tap do |h|
      h[:min_rating] = opts_params[:min_rating].to_i if opts_params[:min_rating].present?
      before_date = parse_date(opts_params[:faved_date])
      h[:max_faved_at] = before_date + 1 if before_date
      after_date = parse_date(opts_params[:faved_date_after])
      h[:min_faved_at] = after_date if after_date
      h[:order] = opts_params[:order] if opts_params[:order]
    end
  end

  def earlest_faved_in_db
    earlest_fave = Picture.faved.collected_by(self).order('faved_at ASC').where('faved_at IS NOT NULL').first
    earlest_fave ? earlest_fave.faved_at : DateTime.now
  end

end