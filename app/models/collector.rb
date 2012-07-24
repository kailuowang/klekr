#monkey patch the flickraw so that I can run the exchange token
require 'net/http'
require 'digest/md5'
require 'json'

module FlickRaw


  # Root class of the flickr api hierarchy.
  class Flickr < Request


    def process_response(req, http_response)
      json = JSON.load(http_response.body.empty? ? "{}" : http_response.body)
      raise FailedResponse.new(json['message'], json['code'], req) if json.delete('stat') == 'fail'
      type, json = json.to_a.first if json.size == 1 and json.all? {|k,v| v.is_a? Hash}

      res = Response.build json, type
      begin
        @token = res.token if res.respond_to? :flickr_type and res.flickr_type == "auth"
      rescue
      end
      res
    end


  end

end



class Collector < ActiveRecord::Base
  extend Collectr::FindOrCreate
  include Collectr::FlickrIcon
  include Collectr::Flickr

  has_many :flickr_streams
  has_many :pictures
  scope :report, order: 'last_login desc'
  def self.from_new_user(auth)
    user = auth.user
    user_id = user.nsid
    create(user_id: user_id, auth_token: auth.token, user_name: user.username, full_name: user.fullname)
  end

  def self.find_or_create_by_auth(auth)
    find_by_user_id(auth.user.nsid) || from_new_user(auth)
  end

  def collection(per_page, page, opts = {})
    pictures_in_db = Picture.faved_by(self, collection_opts(opts), page, per_page)
    if(pictures_in_db.to_a.size == per_page || opts.present?)
      pictures_in_db
    else
      pictures_in_db.to_a + import_from_flickr(per_page - pictures_in_db.size)
    end
  end

  def exchange_token
    if self.access_secret.blank? && self.access_token.blank?
      resp = flickr(self).auth.oauth.getAccessToken
      update_attributes(access_secret: resp["access_token"]["oauth_token_secret"],
                        access_token: resp["access_token"]["oauth_token"]
      )
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