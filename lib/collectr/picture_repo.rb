module Collectr
  class PictureRepo
    include Collectr::Flickr

    def initialize(collector)
      @collector = collector
    end

    def find(string_id)
      if Picture.is_flickr_id?(string_id)
        find_by_flickr_id(string_id)
      else
        find_by_db_id(string_id)
      end
    end

    def build(pic_info)
      find_or_initialize_from_pic_info(pic_info)
    end

    def create_from_sync(pic_info, stream)
      picture = build(pic_info)
      already_synced = !picture.new_record? && stream.synced_with?(picture)
      picture.synced_by(stream) unless already_synced
      return picture, !already_synced
    end

    def new_pictures(opts = {})
      default_opts = {limit: 10, offset: 0}
      opts.reverse_merge!(default_opts)
      scope = Picture.collected_by(@collector).
                      limit(opts[:limit].to_i).
                      offset(opts[:offset].to_i).
                      includes(:flickr_streams, :collector)

      if Rails.env.production?
        scope = scope.from("`pictures` USE INDEX (new_pictures_index)")
      end

      scope = unless opts[:viewed]
        scope.unviewed.desc
      else
        scope.order('created_at DESC')
      end

      if opts[:type].present?
        scope = scope.joins(:flickr_streams)
        scope.where("#{::FlickrStream.table_name}.type = ?", opts[:type])
      else
        scope
      end
    end

    # Make method public for testing
    def find_or_initialize_from_pic_info(pic_info)
      url = get_photopage_url(pic_info)
      Picture.where(collector_id: @collector, url: url).includes(:flickr_streams).first ||
        Picture.new.tap do |picture|
          picture.url = url
          picture.pic_info = pic_info
          # Handle description differently based on pic_info type
          if pic_info.respond_to?(:to_hash)
            picture.description = pic_info.to_hash.delete('description')
          elsif pic_info.respond_to?(:pic_info_dump) && pic_info.pic_info_dump.is_a?(Array) && pic_info.pic_info_dump.first.is_a?(Hash)
            picture.description = pic_info.pic_info_dump.first['description']
          end
          picture.collector = @collector
        end
    end
    
    # Process multiple picture infos in a batch for better efficiency
    def build_batch(pic_infos)
      return [] if pic_infos.empty?
      
      # Step 1: Extract URLs for all the pictures
      url_to_pic_info = {}
      pic_infos.each do |pic_info|
        begin
          # Skip if missing essential photo identification
          if pic_info.is_a?(Hash) && pic_info['id'].blank?
            Rails.logger.warn("Skipping photo without ID: #{pic_info.inspect}")
            next
          end
          
          # Log a sample for debugging
          if url_to_pic_info.empty?
            Rails.logger.debug("Sample pic_info for batch processing: #{pic_info.inspect}")
            if pic_info.is_a?(Hash)
              Rails.logger.debug("Critical fields for URL: " + {
                id: pic_info['id'],
                secret: pic_info['secret'],
                server: pic_info['server'],
                farm: pic_info['farm'],
                url_s: pic_info['url_s'],
                url_m: pic_info['url_m']
              }.inspect)
            end
          end
          
          # Ensure we always have the URLs we need
          if pic_info.is_a?(Hash) && pic_info['id'].present?
            # Always complete the URL fields for required sizes
            url_fields = ['url_s', 'url_m', 'url_z', 'url_b']
            need_complete_info = false
            
            # Check if we're missing server, farm, or secret fields (needed for URL construction)
            if pic_info['server'].blank? || pic_info['farm'].blank? || pic_info['secret'].blank?
              Rails.logger.warn("Photo missing server/farm/secret, fetching complete info for ID: #{pic_info['id']}")
              need_complete_info = true
            end
            
            # Check if we're missing any of the URL fields we need
            if !need_complete_info && url_fields.any? { |field| pic_info[field].blank? }
              Rails.logger.info("Photo missing some URL fields, may need to construct them: #{pic_info['id']}")
            end
            
            # Get complete info if needed
            if need_complete_info
              begin
                if self.respond_to?(:get_complete_photo_info)
                  complete_info = get_complete_photo_info(pic_info['id'], @collector)
                  if complete_info
                    # Merge complete info but preserve URLs and other fields from original
                    preserved_fields = pic_info.select { |k, v| v.present? && k.to_s.start_with?('url_') }
                    pic_info = complete_info.merge(preserved_fields)
                    Rails.logger.debug("Enhanced photo info: server=#{pic_info['server']}, farm=#{pic_info['farm']}")
                  end
                else
                  Rails.logger.warn("get_complete_photo_info method not available, skipping enhancement")
                end
              rescue => e
                Rails.logger.error("Failed to get complete info: #{e.message}")
              end
            end
            
            # Ensure we have URLs for all sizes by constructing them if needed
            if pic_info['server'].present? && pic_info['farm'].present? && pic_info['secret'].present?
              url_fields.each do |field|
                size_code = field.split('_').last # Extract 's', 'm', etc.
                if pic_info[field].blank?
                  pic_info[field] = "https://farm#{pic_info['farm']}.staticflickr.com/#{pic_info['server']}/#{pic_info['id']}_#{pic_info['secret']}_#{size_code}.jpg"
                  Rails.logger.info("Generated missing URL #{field}: #{pic_info[field]}")
                end
                
                # Verify URL looks valid
                if !pic_info[field].start_with?("http")
                  Rails.logger.warn("Invalid URL for #{field}, regenerating: #{pic_info[field]}")
                  pic_info[field] = "https://farm#{pic_info['farm']}.staticflickr.com/#{pic_info['server']}/#{pic_info['id']}_#{pic_info['secret']}_#{size_code}.jpg"
                end
              end
            end
          end
          
          url = get_photopage_url(pic_info)
          url_to_pic_info[url] = pic_info
        rescue => e
          Rails.logger.error("Failed to get URL for picture: #{e.message}")
        end
      end
      
      # Step 2: Find all existing pictures in one database query
      urls = url_to_pic_info.keys
      existing_pictures = Picture.where(collector_id: @collector, url: urls).includes(:flickr_streams).index_by(&:url)
      
      # Step 3: Create new pictures for those not in database
      result = []
      url_to_pic_info.each do |url, pic_info|
        if existing_pictures[url]
          # Use existing picture
          result << existing_pictures[url]
        else
          # Create new picture
          result << Picture.new.tap do |picture|
            picture.url = url
            picture.pic_info = pic_info
            # Handle description differently based on pic_info type
            if pic_info.respond_to?(:to_hash)
              picture.description = pic_info.to_hash.delete('description')
            elsif pic_info.respond_to?(:pic_info_dump) && pic_info.pic_info_dump.is_a?(Array) && pic_info.pic_info_dump.first.is_a?(Hash)
              picture.description = pic_info.pic_info_dump.first['description']
            end
            picture.collector = @collector
          end
        end
      end
      
      result
    end
    
    private

    def find_by_db_id(string_id)
      pic = Picture.find(string_id)
      if(pic.collector == @collector)
        pic
      else
        find_or_initialize_from_pic_info(pic.pic_info)
      end
    end

    def get_photopage_url(pic_info)
      begin
        # Handle JSON response from our custom FlickrRetriever
        if pic_info.is_a?(Hash) && pic_info['owner'] && pic_info['id']
          return "https://www.flickr.com/photos/#{pic_info['owner']}/#{pic_info['id']}"
        # Handle Flickr-Objects style objects  
        elsif pic_info.respond_to?(:urls) && pic_info.urls.is_a?(Array) && pic_info.urls[0].is_a?(Hash)
          return pic_info.urls[0]["_content"].to_s
        # Handle Picture object with pic_info_dump  
        elsif pic_info.respond_to?(:pic_info_dump) && pic_info.pic_info_dump.is_a?(Array) && pic_info.pic_info_dump.first.is_a?(Hash)
          info = pic_info.pic_info_dump.first
          return "https://www.flickr.com/photos/#{info['owner']}/#{info['id']}"
        # Fallback with owner and id directly from pic_info attributes
        elsif pic_info.respond_to?(:owner) && pic_info.respond_to?(:id)
          owner_id = pic_info.respond_to?(:owner_id) ? pic_info.owner_id : pic_info.owner
          return "https://www.flickr.com/photos/#{owner_id}/#{pic_info.id}"
        else
          # Last resort: extract as much info as we can
          id = extract_attribute(pic_info, 'id')
          owner = extract_attribute(pic_info, 'owner') || 
                 extract_attribute(pic_info, 'owner_id') || 
                 extract_attribute(pic_info, 'user_id')
                 
          if id && owner
            return "https://www.flickr.com/photos/#{owner}/#{id}"
          else
            raise "Unable to determine photopage URL for #{pic_info.inspect}"
          end
        end
      rescue => e
        Rails.logger.error("Error generating photo URL: #{e.message}")
        raise "Unable to determine photopage URL: #{e.message}"
      end
    end
    
    # Helper to extract attributes from various object types
    def extract_attribute(obj, attr_name)
      if obj.is_a?(Hash) && obj[attr_name]
        return obj[attr_name]
      elsif obj.respond_to?(attr_name.to_sym)
        return obj.send(attr_name.to_sym)
      elsif obj.respond_to?(:to_hash) && obj.to_hash[attr_name]
        return obj.to_hash[attr_name]
      end
      nil
    end

    def find_by_flickr_id(string_id)
      begin
        fid, secret = string_id.split('_')
        # Use the find method in flickr-objects
        pic_info = flickr.photos.find(fid)
        find_or_initialize_from_pic_info(pic_info)
      rescue => e
        Rails.logger.error("Error finding photo by ID: #{e.message}")
        raise "Unable to find photo with ID #{string_id}: #{e.message}"
      end
    end

  end
end