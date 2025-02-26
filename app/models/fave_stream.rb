class FaveStream < FlickrStream
  include Collectr::Flickr
  
  def stream_url
    user_url + "favorites/?view=md"
  end

  def type_display
    "Faves"
  end
  
  def flickr_picture_retriever
    @flickr_picture_retriever ||= Collectr::FlickrPictureRetriever.new(
      module: :photos, 
      method: :get_favorites, 
      time_field: :fave_date, 
      user_id: user_id, 
      collector: collector
    )
  end
  
  def sync(since = nil, max_num = 50, verbose = false)
    # Handle the case where verbose is passed as a hash option
    if since.is_a?(Hash) && since.key?(:verbose)
      verbose = since[:verbose]
      since = nil
    end
    
    begin
      since ||= last_sync || 1.month.ago
      photos_synced = 0
      flickr_retriever = Collectr::FlickrRetriever.new(collector)
      
      # Get favorite photos using our custom retriever
      flickr_retriever.get_favorites(user_id, {
        min_upload_date: since.is_a?(Time) || since.is_a?(DateTime) ? since.to_i : nil,
        per_page: max_num.is_a?(Numeric) ? max_num : 50
      }).each do |pic_info|
        begin
          _, newly_synced = picture_repo.create_from_sync(pic_info, self)
          photos_synced += 1 if newly_synced
        rescue => e
          Rails.logger.error("Error creating picture from sync: #{e.message}")
        end
      end
      
      # Update sync timestamp
      update_attribute(:last_sync, DateTime.now)
      print "." if verbose && photos_synced > 0
      photos_synced
    rescue => e
      Rails.logger.error("Error in fave sync for stream #{id} (#{username}): #{e.message}")
      update_attribute(:last_sync, DateTime.now) # Still update to prevent repeated failures
      0 # Return 0 pictures synced on error
    end
  end
end
