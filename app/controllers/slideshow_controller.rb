class SlideshowController < ApplicationController
  include Collectr::PictureControllerHelper
  before_filter :authenticate, except: [:exhibit, :exhibit_pictures]

  def flickr_stream
    id = params[:id].to_i
    @stream = FlickrStream.find(id)
    check_stream_access(@stream)
    @more_pictures_path = pictures_flickr_stream_path(id)
    @empty_message = "#{@stream} has no pictures."
  end

  def show
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
    @disable_navigation = current_collector.blank?
    @collector = ::Collector.find(params[:collector_id])
    @more_pictures_path = exhibit_pictures_slideshow_path(params.slice(:collector_id, :order_by))
    @empty_message = "#{@collector.user_name} has not faved any pictures yet."
    @default_filters = default_filters
    @exhibit_params = exhibit_params
    @exhibit_name = exhibit_name
    @icon =  @collector.is_editor? ? nil : @collector
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

  private

  def exhibit_params
    params.slice(:collector_id, :rating, :faveDate, :faveDateAfter)
  end

  def filter_params
    params.slice(:min_rating, :faved_date, :faved_date_after)
  end

  def render_fave_pictures(collector, opts = {})
    render_json_pictures collector.collection( params[:num].to_i,
                                               params[:page].to_i,
                                               opts.merge(filter_params))
  end

  def exhibit_name
    if @collector.is_editor?
      "Editors' Choice"
    else
      @collector.user_name + "'s klekr faves"
    end
  end

  def check_stream_access(stream)
    if(stream.collector != current_collector)
      redirect_to user_path(stream.user_id, type: stream.class.name)
    end
  end

  def default_filters
    filtersParams = params.slice(:rating, :faveDate, :faveDateAfter)
    filtersParams.to_json if (filtersParams.present?)
  end

end