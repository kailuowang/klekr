class SlideshowController < ApplicationController
  include Collectr::PictureControllerHelper
  include Collectr::SlideshowControllerHelper

  before_filter :authenticate, except: [:exhibit, :exhibit_pictures, :editors_choice, :flickr_stream, :flickr_stream_pictures]
  before_filter :set_navigation_links, only: [:exhibit, :show, :flickr_stream, :faves, :editors_choice]

  def flickr_stream
    id = params[:id].to_i
    slideshow_for_stream(FlickrStream.find(id))
  end

  def flickr_stream_pictures
    page = params[:page] ? params[:page].to_i : 1
    per_page = params[:num] ? params[:num].to_i : 1
    @stream = FlickrStream.find(params[:id])
    render_json_pictures @stream.get_pictures(per_page, page)
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
    opts = params.to_hash.to_options.slice(:offset, :limit, :type, :viewed)
    new_pictures = Collectr::PictureRepo.new(current_collector).new_pictures(opts)
    render_json_pictures(new_pictures)
  end


end