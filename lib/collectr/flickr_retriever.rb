module Collectr
  class FlickrRetriever
    # A modern retriever for Flickr photos that works with OAuth
    
    def initialize(collector)
      @collector = collector
    end
    
    # Retrieve favorite photos for a user
    def get_favorites(user_id, options = {})
      # Default options
      opts = {
        per_page: 50,
        page: 1,
        min_upload_date: nil,
        max_upload_date: nil
      }.merge(options)
      
      # Build params - request all URL sizes and metadata
      params = {
        method: 'flickr.favorites.getList',
        format: 'json',
        nojsoncallback: 1,
        user_id: user_id,
        per_page: opts[:per_page],
        page: opts[:page],
        extras: 'date_upload,owner_name,description,server,farm,url_sq,url_s,url_m,url_z,url_l,url_b,url_o'
      }
      
      # Add date filters if provided
      params[:min_upload_date] = opts[:min_upload_date].to_i if opts[:min_upload_date]
      params[:max_upload_date] = opts[:max_upload_date].to_i if opts[:max_upload_date]
      
      Rails.logger.debug("Making getFavorites call with params: #{params.inspect}")
      
      # Make the OAuth request
      response = make_oauth_request(params)
      return [] unless response
      
      # Parse and return the photos
      photos = JSON.parse(response.body)
      if photos['stat'] == 'ok' && photos['photos'] && photos['photos']['photo']
        return photos['photos']['photo']
      else
        Rails.logger.error("Error fetching favorites: #{photos['message'] if photos['stat'] != 'ok'}")
        return []
      end
    end
    
    # Retrieve public photos for a user
    def get_public_photos(user_id, options = {})
      # Default options
      opts = {
        per_page: 50,
        page: 1,
        min_upload_date: nil,
        max_upload_date: nil
      }.merge(options)
      
      # Build params - request all URL sizes
      params = {
        method: 'flickr.people.getPublicPhotos',
        format: 'json',
        nojsoncallback: 1,
        user_id: user_id,
        per_page: opts[:per_page],
        page: opts[:page],
        extras: 'date_upload,owner_name,description,server,farm,url_sq,url_s,url_m,url_z,url_l,url_b,url_o'
      }
      
      # Add date filters if provided
      params[:min_upload_date] = opts[:min_upload_date].to_i if opts[:min_upload_date]
      params[:max_upload_date] = opts[:max_upload_date].to_i if opts[:max_upload_date]
      
      Rails.logger.debug("Making getPublicPhotos call with params: #{params.inspect}")
      
      # Make the OAuth request
      response = make_oauth_request(params)
      return [] unless response
      
      # Parse and return the photos
      photos = JSON.parse(response.body)
      if photos['stat'] == 'ok' && photos['photos'] && photos['photos']['photo']
        # Log and debug the photo data
        Rails.logger.debug("Received #{photos['photos']['photo'].size} photos from Flickr API")
        
        if photos['photos']['photo'].first
          sample = photos['photos']['photo'].first
          Rails.logger.debug("Sample photo data: #{sample.inspect}")
        end
        
        # Add required fields if missing - essential for URL generation
        photos['photos']['photo'].map do |photo|
          # Make sure all required fields for URL generation are present
          if photo['server'].blank? || photo['id'].blank? || photo['secret'].blank? || photo['farm'].blank?
            Rails.logger.warn("Photo missing required fields: #{photo.inspect}")
            
            # Get complete photo info using getInfo call (only when id is present)
            if photo['id'].present?
              begin
                complete_info = get_photo_info(photo['id'])
                # Merge the additional info with existing photo data
                photo.merge!(complete_info) if complete_info
              rescue => e
                Rails.logger.error("Failed to get complete photo info: #{e.message}")
              end
            end
          end
          photo
        end
      else
        Rails.logger.error("Error fetching public photos: #{photos['message'] if photos['stat'] != 'ok'}")
        return []
      end
    end
    
    # Get complete info for a single photo (public method to be used elsewhere too)
    def get_photo_info(photo_id)
      # Build params for getInfo call
      params = {
        method: 'flickr.photos.getInfo',
        format: 'json',
        nojsoncallback: 1,
        photo_id: photo_id
      }
      
      # Make the request
      response = make_oauth_request(params)
      return nil unless response
      
      # Parse the response
      begin
        info = JSON.parse(response.body)
        if info['stat'] == 'ok' && info['photo']
          Rails.logger.debug("Got photo info for photo #{photo_id}")
          return info['photo']
        else
          Rails.logger.error("Error fetching photo info: #{info['message'] if info['stat'] != 'ok'}")
          return nil
        end
      rescue => e
        Rails.logger.error("Failed to parse photo info response: #{e.message}")
        return nil
      end
    end
    
  private
    
    def make_oauth_request(params)
      # Get OAuth tokens - try both new and old column names for compatibility
      oauth_token = @collector.oauth_token || @collector.access_token
      oauth_token_secret = @collector.oauth_token_secret || @collector.access_secret
      
      if oauth_token.present? && oauth_token_secret.present?
        # Create OAuth access token
        access_token = OAuth::AccessToken.new(
          Collectr::FLICKR_OAUTH_CONSUMER,
          oauth_token,
          oauth_token_secret
        )
        
        # Build the query string
        query = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
        
        # For debugging
        Rails.logger.debug("Making OAuth request: /services/rest/?#{query}")
        
        # Make the request
        begin
          response = access_token.get("/services/rest/?#{query}")
          
          if response.code.to_i == 200
            Rails.logger.debug("OAuth request successful, response size: #{response.body.size}")
            return response
          else
            Rails.logger.error("OAuth request failed with status code: #{response.code}")
            return nil
          end
        rescue => e
          Rails.logger.error("OAuth request failed: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n")) if e.backtrace
          return nil
        end
      else
        Rails.logger.error("Cannot make Flickr request: missing OAuth credentials for collector #{@collector&.id}")
        
        # Try fallback to global client if there are configured tokens
        if Collectr::FlickrConfig['access_token'].present? && Collectr::FlickrConfig['access_token_secret'].present?
          Rails.logger.info("Trying fallback to global OAuth tokens")
          
          access_token = OAuth::AccessToken.new(
            Collectr::FLICKR_OAUTH_CONSUMER,
            Collectr::FlickrConfig['access_token'],
            Collectr::FlickrConfig['access_token_secret']
          )
          
          query = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
          
          begin
            return access_token.get("/services/rest/?#{query}")
          rescue => e
            Rails.logger.error("Fallback OAuth request failed: #{e.message}")
            return nil
          end
        else
          return nil
        end
      end
    end
  end
end