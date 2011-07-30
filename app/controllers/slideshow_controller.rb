class SlideshowController < ApplicationController
  include Collectr::PictureControllerHelper
  before_filter :authenticate

  def flickr_stream
    id = params[:id].to_i
    @slideshow_name = FlickrStream.find(id).to_s
    @first_picture_path = first_picture_flickr_stream_path(id)
    @more_pictures_path = pictures_flickr_stream_path(id)
  end

  def show
    id = params[:id]
    @slideshow_name = @current_collector.user_name + " 's Slide Show"
    @first_picture_path = id ? picture_path(id) : current_pictures_path
    @more_pictures_path = new_pictures_slideshow_path
  end


  def new_pictures
    exclude_ids = params[:exclude_ids].map(&:to_i)
    num_of_pictures = params[:num].to_i
    new_pictures = Picture.new_pictures_by(current_collector, num_of_pictures, exclude_ids)

    render_json_pictures(new_pictures)
  end


end