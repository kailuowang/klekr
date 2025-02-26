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
    per_page = params[:num] ? params[:num].to_i : 10  # Default to 10 photos per request
    @stream = FlickrStream.find(params[:id])
    
    # Set a reasonable maximum for per_page to prevent too many photos
    per_page = [per_page, 50].min
    
    # Add a page limit to prevent too many pages being requested at once
    max_page = 3
    if page > max_page
      Rails.logger.warn("Requested page #{page} exceeds maximum page limit of #{max_page}")
      page = max_page
    end
    
    Rails.logger.info("Retrieving page #{page} with #{per_page} photos for stream #{@stream.id}")
    
    # Force real-time mode or check if real-time param is passed
    real_time = params[:real_time] == 'true'
    
    if real_time
      # Always get fresh pictures from Flickr API in real-time
      Rails.logger.info("Loading pictures in real-time from Flickr API for stream #{@stream.id}")
      pictures = @stream.get_pictures(per_page, page)
    else
      # First try to get pictures from the database - with pagination
      pictures = @stream.pictures.includes(:flickr_streams, :collector)
                       .order(created_at: :desc)
                       .page(page)
                       .per_page(per_page)
      
      # Fall back to the API if no pictures are found
      if pictures.empty? && page <= 2  # Only try API for first two pages
        Rails.logger.info("No pictures found in database for page #{page}, getting from Flickr API")
        pictures = @stream.get_pictures(per_page, page)
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