module Collectr

  FlickrConfig = YAML.load_file("#{Rails.root}/config/flickr.yml")[Rails.env]

  FlickRaw.api_key        = FlickrConfig['api_key']
  FlickRaw.shared_secret  = FlickrConfig['shared_secret']


  #FlickRawOptions['timeout'] = 15
  #if DevFlickrAuthToken.present?
  #  begin
  #    flickr.auth.checkToken :auth_token => DevFlickrAuthToken
  #  rescue
  #    Rails.logger.error("failed to validate the auth token stored in the flickr.yml")
  #  end
  #end
end
