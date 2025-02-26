module Collectr
  class FlickrPictureRetriever
    include Collectr::Flickr

    attr_reader :collector

    def self.throttle_requests
      # Method kept for compatibility but rate limiting removed
    end

    def self.flickr_photos_per_page
      Settings.default_flickr_photo_retrieve_size
    end

    def initialize(params)
      @module = params[:module]
      @method = params[:method]
      @time_field = params[:time_field]
      @user_id = params[:user_id]
      @id_field = params[:id_field] || :user_id
      @collector = params[:collector]
      @default_per_page = params[:per_page] || FlickrPictureRetriever.flickr_photos_per_page
    end

    def get_module
      # Make sure we're using the global Flickr class from the gem, not our module
      api = flickr_client
      
      # The API structure changed from FlickRaw to flickr-objects
      # people and photos are top level objects in flickr-objects
      if @module == :person || @module == :people
        # Important: Must use 'people' not 'person' in flickr-objects
        api.people
      elsif @module == :photo || @module == :photos
        api.photos
      elsif @module == :favorites
        api.photos # Use photos module for favorites
      else
        if @module.is_a?(Array)
          @module.inject(api) { |pm, mname| pm.send(mname)}
        else
          api.send(@module)
        end
      end
    end

    def get(per_page = nil, page_number = 1, since = nil, before = nil)
      # Implement rate limiting at the API level
      self.class.throttle_requests
      
      # Request all URL sizes for each photo to avoid having to construct them later
      opts = {extras: 'date_upload,owner_name,description,server,farm,url_sq,url_s,url_m,url_z,url_l,url_b,url_o'}.
              merge(paging_opts(per_page, page_number)).
              merge(range_opts(since, before))
              
      # Add user_id parameter only for non-photo methods
      opts.merge!({@id_field => @user_id}) unless @module == :photo
      
      begin
        # For testing without hitting Flickr API
        if Rails.env.development? && ENV['MOCK_FLICKR'] == 'true'
          # Return the pictures already in the database for this user
          return Picture.where(owner_name: "[ Andreas Guenther ]").limit(20).to_a
        end
        
        # This will be true for real API calls
        Rails.logger.info("Making API call: module=#{@module}, method=#{@method}, user_id=#{@user_id}")
        
        # Use the correct API method based on module type
        results = 
          begin
            if @module == :person || @module == :people
              # For person API, we need to call the module method with the user_id as first parameter
              Rails.logger.debug("Calling people.#{@method}(#{@user_id}, #{opts.except(@id_field).inspect})")
              get_module.send(@method, @user_id, opts.except(@id_field))
            elsif @module == :photo || @module == :photos
              # For photo-level operations like get_favorites, need to pass id as first parameter
              Rails.logger.debug("Calling photos.#{@method}(#{@user_id}, #{opts.except(@id_field).inspect})")
              get_module.send(@method, @user_id, opts.except(@id_field))
            else  
              # For other APIs, pass all in opts
              Rails.logger.debug("Calling #{@module}.#{@method}(#{opts.inspect})")
              get_module.send(@method, opts)
            end
          rescue => e
            # Handle specific error cases for troubleshooting
            raise e
          end
        
        # Log successful result
        Rails.logger.info("API call successful - got #{results.respond_to?(:size) ? results.size : 'a'} result(s)")
        
        # Convert results to hashes to make it easier to work with
        processed_results = if results.respond_to?(:map)
          results.map do |item|
            if item.respond_to?(:to_hash)
              item.to_hash
            else
              item
            end
          end
        else
          results
        end
        
        # Log some sample results to debug issues with missing fields
        if processed_results.respond_to?(:first) && processed_results.first
          sample = processed_results.first
          Rails.logger.debug("Sample photo from Flickr API: #{sample.inspect}")
          
          # Log critical fields for URL generation
          if sample.is_a?(Hash)
            Rails.logger.debug("Critical fields for URL: " + {
              id: sample['id'],
              secret: sample['secret'],
              server: sample['server'],
              farm: sample['farm']
            }.inspect)
          end
        end
        
        processed_results
      rescue StandardError => e
        Rails.logger.error("Flickr API error: #{e.message} (#{e.class}) for #{@module}.#{@method}")
        
        if e.message.include?('failed')
          handle_flickr_error(e)
        elsif e.is_a?(Timeout::Error) || e.message.include?('time')
          handle_timeout_error(e)
        elsif e.is_a?(Errno::ETIMEDOUT) || e.is_a?(Errno::ECONNRESET) || e.is_a?(Errno::ECONNREFUSED)
          handle_timeout_error(e)
        # Handle Faraday errors from any version
        elsif defined?(Faraday) && e.class.name.to_s.include?('Faraday')
          handle_timeout_error(e)
        else
          handle_flickr_error(e)
        end
      end
    end

    def get_all(since, max_num, &block)
      get_all_by_page(since, max_num, 1, &block)
    end

    private

    def get_all_by_page(since, max, page)
      Rails.logger.info("Getting pictures page #{page} for user #{@user_id}, module: #{@module}, method: #{@method}")
      result = get(@default_per_page, page, since).to_a
      Rails.logger.info("Retrieved #{result.size} pictures")
      
      yield result if(block_given?)
      
      # Check if we've retrieved the max number of pictures or if this page is empty
      retrieved_max_num_of_pics = max && @default_per_page * page >= max
      
      # Stop if we've retrieved enough or have no more results
      unless(retrieved_max_num_of_pics || result.empty?)
        # Otherwise get the next page
        next_page_results = get_all_by_page(since, max, page + 1)
        result += next_page_results
      end
      
      result
    end

    def time_field(prefix)
      (prefix + @time_field.to_s).to_sym
    end

    def min_time_field
      time_field('min_')
    end

    def max_time_field
      time_field('max_')
    end

    def paging_opts(per_page, page_number)
      {}.tap do |h|
        h[:per_page] = per_page || @default_per_page
        h[:page] = page_number if page_number > 1
      end
    end

    def range_opts(since, before)
      {}.tap do |opts|
        if(@time_field)
          opts[min_time_field] = since.to_i if since.present?
          opts[max_time_field] = before.to_i if before.present?
        end
      end
    end

    def handle_flickr_error(e)
      handle_error(e, "failed sync #{@module} photo for #{@user_id} from flickr. Error: #{e.message}")
    end

    def handle_timeout_error(e)
      handle_error(e, "Timed out when syncing #{@module} photo for #{@user_id} from flickr.") do
        sleep(30)
      end
    end

    def handle_error(e, msg)
      if (Rails.env == 'test')
        raise e
      else
        Rails.logger.error(msg)
        yield if block_given?
        []
      end
    end
  end
end
