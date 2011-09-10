class SlideshowController < ApplicationController
  include Collectr::PictureControllerHelper
  before_filter :authenticate

  def flickr_stream
    id = params[:id].to_i
    @stream = FlickrStream.find(id)
    @more_pictures_path = pictures_flickr_stream_path(id)
    @alternative_stream = @stream.alternative_stream
    @empty_message = "#{@stream} has no pictures."
    @navigation_options = @navigation_options.insert(0, name: @stream.alternative_stream.to_s, path: flickr_stream_path(@stream.alternative_stream))
  end

  def show
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