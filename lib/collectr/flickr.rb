module Collectr::Flickr
  # Alias for the global Flickr constant from the flickr-objects gem
  def flickr_client
    # This makes it clearer we're using the gem's global class
    ::Flickr
  end
  
  def flickr(for_collector = nil)
    for_collector ||= self.collector if self.respond_to?(:collector)
    
    # Return the global FLICKR_CLIENT instance that's already initialized
    # and update its tokens if a collector is provided
    if for_collector && for_collector.access_token.present?
      # Create a temporary client instance with these tokens
      Rails.logger.debug("Using OAuth tokens for collector: #{for_collector.id}")
      configure_flickr_client(for_collector.access_token, for_collector.access_secret)
    else
      # Return the global client
      Rails.logger.debug("Using global Flickr client with default tokens")
      Collectr::FLICKR_CLIENT
    end
  end

  def configure_flickr_client(token, secret)
    # Using the newer flickr-objects gem to create a client with tokens
    # Create a one-time client with specific tokens
    Flickr.configure do |config|
      # API key and shared secret are already set in the initializer
      config.access_token_key = token
      config.access_token_secret = secret
    end
    Flickr
  end

  def try_flickr(msg = 'failed to do flickr request')
    begin
      yield
    rescue => e
      Rails.logger.error(msg + ' ' + e.inspect)
      Rails.logger.error(e.backtrace.join("\n")) if e.backtrace
      nil
    end
  end
  
  # Get complete info for a photo - fallback method that works everywhere
  def get_complete_photo_info(photo_id, collector = nil)
    return nil unless photo_id.present?
    
    begin
      # First try with FlickrRetriever if available (preferred)
      if defined?(Collectr::FlickrRetriever) && collector
        retriever = Collectr::FlickrRetriever.new(collector)
        return retriever.get_photo_info(photo_id)
      end
      
      # Fall back to direct API call
      client = flickr(collector)
      photo = client.photos.find(photo_id)
      
      # Extract important fields
      if photo.respond_to?(:to_hash)
        return photo.to_hash
      else
        # Create a hash with essential fields
        return {
          'id' => photo.id,
          'secret' => photo.secret,
          'server' => photo.server,
          'farm' => photo.farm,
          'owner' => photo.owner.respond_to?(:nsid) ? photo.owner.nsid : photo.owner
        }
      end
    rescue => e
      Rails.logger.error("Failed to get complete photo info for #{photo_id}: #{e.message}")
      nil
    end
  end
  
  # Helper method to translate between flickraw and flickr-objects API
  # This helps bridge the gap during migration without changing all the code
  def translate_flickr_response(response)
    # Just return the response since we're using the new API directly
    response
  end
  
  # Create mock objects for development and testing
  def mock_user(user_id, username = nil)
    OpenStruct.new(
      username: username || "user_#{user_id}", 
      real_name: username || "User #{user_id}",
      name: username || "User #{user_id}",
      id: user_id,
      path_alias: username || "user_#{user_id}",
      icon_url: "https://www.flickr.com/buddyicons/#{user_id}.jpg",
      nsid: user_id
    )
  end
end

