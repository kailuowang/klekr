module Collectr
  # Load Flickr configuration
  FlickrConfig = YAML.safe_load(File.read("#{Rails.root}/config/flickr.yml"), aliases: true)[Rails.env]

  # Initialize using OAuth with flickr-objects
  require 'flickr-objects'
  require 'oauth'
  require 'faraday'
  
  # Define TimeoutError for Faraday 1.x compatibility
  module Faraday
    module Error
      TimeoutError = Class.new(StandardError) unless defined?(TimeoutError)
    end
  end
  
  Flickr.configure do |config|
    config.api_key = FlickrConfig['api_key']
    config.shared_secret = FlickrConfig['shared_secret']
    
    # Set OAuth access tokens if available
    if FlickrConfig['access_token'].present? && FlickrConfig['access_token_secret'].present?
      config.access_token_key = FlickrConfig['access_token']
      config.access_token_secret = FlickrConfig['access_token_secret']
    end
  end
  
  # Create an OAuth consumer for low-level access if needed
  FLICKR_OAUTH_CONSUMER = OAuth::Consumer.new(
    FlickrConfig['api_key'],
    FlickrConfig['shared_secret'],
    {
      site: "https://www.flickr.com",
      request_token_path: "/services/oauth/request_token",
      authorize_path: "/services/oauth/authorize",
      access_token_path: "/services/oauth/access_token"
    }
  )
  
  # Create an access token for authenticated requests if available
  if FlickrConfig['access_token'].present? && FlickrConfig['access_token_secret'].present?
    FLICKR_OAUTH_ACCESS_TOKEN = OAuth::AccessToken.new(
      FLICKR_OAUTH_CONSUMER,
      FlickrConfig['access_token'],
      FlickrConfig['access_token_secret']
    )
  end
  
  # Test the connection if we have OAuth tokens
  if Rails.env.development? && FlickrConfig['access_token'].present?
    begin
      # Test the connection by fetching current user's info
      # Note: Using people.find instead of test.login which is not supported
      user = Flickr.people.find('me')
      Rails.logger.info "Connected to Flickr as: #{user.username}" if user
    rescue => e
      Rails.logger.error "Failed to connect to Flickr API: #{e.message}"
    end
  end
  
  # Make the Flickr client available throughout the application
  FLICKR_CLIENT = Flickr
end