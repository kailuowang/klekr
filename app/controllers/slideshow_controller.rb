class SlideshowController < ApplicationController
  include Collectr::PictureControllerHelper
  include Collectr::SlideshowControllerHelper

  before_action :authenticate, except: [:exhibit, :exhibit_pictures, :editors_choice, :flickr_stream, :flickr_stream_pictures]
  before_action :set_navigation_links, only: [:exhibit, :show, :flickr_stream, :faves, :editors_choice]

  def flickr_stream
    id = params[:id].to_i
    slideshow_for_stream(FlickrStream.find(id))
  end

  def flickr_stream_pictures
    page = params[:page] ? params[:page].to_i : 1
    per_page = params[:num] ? params[:num].to_i : 50  # Default to 50 photos per request
    @stream = FlickrStream.find(params[:id])
    
    # Set a reasonable maximum for per_page based on settings
    per_page = [per_page, Settings.max_items_per_page || 100].min
    
    # Allow a higher page limit to ensure we can load enough photos
    max_page = Settings.max_pages_per_request || 20
    if page > max_page
      Rails.logger.warn("Requested page #{page} exceeds maximum page limit of #{max_page}")
      page = max_page
    end
    
    # Cache key based on parameters
    cache_key = "stream_#{@stream.id}_page_#{page}_per_#{per_page}_#{params[:real_time]}_#{params[:_cacheKey]}"
    
    # Try to use cached data first, with a 5-minute expiration
    pictures = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      Rails.logger.info("Cache miss for #{cache_key} - retrieving fresh data")
      
      # Force real-time mode if the parameter is passed
      real_time = params[:real_time] == 'true'
      
      # Check if the stream needs to be synced
      needs_sync = @stream.last_sync.nil? || @stream.last_sync < 30.minutes.ago
      
      if real_time || needs_sync
        # Get fresh pictures from Flickr API
        Rails.logger.info("Loading pictures from Flickr API for stream #{@stream.id} (real-time=#{real_time}, needs_sync=#{needs_sync})")
        pics = @stream.get_pictures(per_page, page)
        
        # Mark stream as synced if we fetch from API
        @stream.update_attribute(:last_sync, Time.now) if pics.present?
        
        pics
      else
        # Try to get pictures from the database first with pagination
        db_pics = @stream.pictures.includes(:flickr_streams, :collector)
                         .order(created_at: :desc)
                         .page(page)
                         .per_page(per_page)
        
        # Only fall back to API if we don't have enough pictures
        if db_pics.empty? || (db_pics.size < per_page && page == 1)
          Rails.logger.info("Insufficient pictures in DB, getting from Flickr API")
          @stream.get_pictures(per_page, page)
        else
          Rails.logger.info("Using #{db_pics.size} pictures from database")
          db_pics
        end
      end
    end
    
    Rails.logger.info("Returning #{pictures.size} pictures for stream #{@stream.id}")
    render_json_pictures pictures
  end

  def show
    @current_collector.update_attribute(:last_login, DateTime.now)
    if(@current_collector.flickr_streams.count == 0)
      redirect_to(flickr_streams_path)
    end
    @advance_by_progress = true #contrast to progress by paging
    @more_pictures_path = new_pictures_slideshow_path
    @empty_message_partial = 'no_new_pictures'
  end

  def faves
    @more_pictures_path = fave_pictures_slideshow_path
    @empty_message = "You haven't fave any pictures yet"
  end

  def exhibit_login
    redirect_to(exhibit_params.merge(action: :exhibit))
  end

  def exhibit
    @html_url = exhibit_slideshow_url(exhibit_params)
    @collector = ::Collector.find(params[:collector_id])
    @icon =  @collector
    @exhibit_name = @collector.user_name + "'s faves"
    render_exhibit
  end

  def editors_choice
    @icon = 'logo48.jpeg'
    @html_url = editors_choice_url
    @bottom_links = [:editors_choice_rss, :editor_choice_google_currents]
    @collector = Collectr::Editor.new.ensure_editor_collector
    @exhibit_name = "Editors' Choice"
    params.merge!(rating: 2, order_by: 'date', collector_id: @collector.id)
    render_exhibit
  end

  def exhibit_pictures
    order_field = {'photographer' => 'owner_name', 'date' => 'faved_at desc'}[params[:order_by]] || 'owner_name'
    render_fave_pictures ::Collector.find(params[:collector_id]), order: order_field
  end

  def fave_pictures
    render_fave_pictures current_collector
  end

  def new_pictures
    # Convert to permitted parameters for Rails 7.1
    permitted_params = params.permit(:offset, :limit, :type, :viewed)
    new_pictures = Collectr::PictureRepo.new(current_collector).new_pictures(permitted_params)
    render_json_pictures(new_pictures)
  end


end