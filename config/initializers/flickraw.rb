module Collectr

  flickr_config = YAML.load_file("#{Rails.root}/config/flickr.yml")[Rails.env]

  FlickRaw.api_key        = flickr_config['api_key']
  FlickRaw.shared_secret  = flickr_config['shared_secret']
  if(flickr_config['auth_token'].present?)
    auth                    = flickr.auth.checkToken :auth_token => flickr_config['auth_token']
    FLICKR_USER_ID = auth.user.nsid
  end
end
