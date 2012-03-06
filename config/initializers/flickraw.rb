module Collectr

  flickr_config = YAML.load_file("#{Rails.root}/config/flickr.yml")[Rails.env]

  FlickRaw.api_key        = flickr_config['api_key']
  FlickRaw.shared_secret  = flickr_config['shared_secret']
  DevFlickrAuthToken      = flickr_config['auth_token']
  if DevFlickrAuthToken.present?
    begin
      flickr.auth.checkToken :auth_token => DevFlickrAuthToken
    rescue
      Rails.logger.error("failed to validate the auth token stored in the flickr.yml")
    end
  end
  DevFlickrUserId = flickr_config['user_id']
  DevFlickrUserName = flickr_config['user_name']

  TestFlickrAuthToken      = flickr_config['test_auth_token']
  TestFlickrUserId = flickr_config['test_user_id']
  TestFlickrUserName = flickr_config['test_user_name']
  EditorFlickrAuthToken = flickr_config['editor_user_auth_token']

end
