module Collectr

  flickr_config = YAML.load_file("#{Rails.root}/config/flickr.yml")[Rails.env]

  FlickRaw.api_key        = flickr_config['api_key']
  FlickRaw.shared_secret  = flickr_config['shared_secret']

  if(flickr_config['auth_token'].present?)
    begin
      flickr.auth.checkToken :auth_token => flickr_config['auth_token']
    rescue
      Rails.logger.error("failed to validate the auth token stored in the flickr.yml")
    end
  end
  FlickrUserId = flickr_config['user_id']
end
