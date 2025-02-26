
class UploadStream < FlickrStream
  include Collectr::Flickr

  def stream_url
    user_url
  end

  def type_display
    "Works"
  end
  
  def flickr_picture_retriever
    @flickr_picture_retriever ||= Collectr::FlickrPictureRetriever.new(
      module: :people, 
      method: :get_public_photos, 
      time_field: :upload_date, 
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
      
      # Get public photos using our custom retriever
      pic_infos = flickr_retriever.get_public_photos(user_id, {
        min_upload_date: since.is_a?(Time) || since.is_a?(DateTime) ? since.to_i : nil,
        per_page: max_num.is_a?(Numeric) ? max_num : 50
      })
      
      # Process pictures in batches of 100 for efficiency
      pic_infos.each_slice(100) do |batch|
        # Create pictures with batch processing
        picture_repo.build_batch(batch).each do |picture|
          begin
            # Check if the picture is already synchronized with this stream
            already_synced = !picture.new_record? && synced_with?(picture)
            
            # Synchronize the picture if not already done
            unless already_synced
              picture.synced_by(self)
              photos_synced += 1
            end
          rescue => e
            Rails.logger.error("Error creating picture from sync: #{e.message}")
          end
        end
      end
      
      # Update sync timestamp
      update_attribute(:last_sync, DateTime.now)
      print "." if verbose && photos_synced > 0
      photos_synced
    rescue => e
      Rails.logger.error("Error in upload sync for stream #{id} (#{username}): #{e.message}")
      update_attribute(:last_sync, DateTime.now) # Still update to prevent repeated failures
      0 # Return 0 pictures synced on error
    end
  end
end