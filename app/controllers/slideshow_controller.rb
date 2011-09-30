class SlideshowController < ApplicationController
  include Collectr::PictureControllerHelper
  before_filter :authenticate

  def flickr_stream
    id = params[:id].to_i
    @stream = FlickrStream.find(id)
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
    @empty_message = "You haven't collect any pictures yet"
  end

  def fave_pictures
    render_json_pictures current_collector.collection( params[:num].to_i, params[:page].to_i, params.slice(:min_rating))
  end

  def new_pictures
    opts = params.to_hash.to_options.slice(:offset, :limit, :type)
    new_pictures = Collectr::PictureRepo.new(current_collector).new_pictures(opts)
    render_json_pictures(new_pictures)
  end


end