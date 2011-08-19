class SlideshowController < ApplicationController
  include Collectr::PictureControllerHelper
  before_filter :authenticate

  def flickr_stream
    id = params[:id].to_i
    @stream = FlickrStream.find(id)
    @slideshow_name = FlickrStream.find(id).to_s
    @more_pictures_path = pictures_flickr_stream_path(id)
    @alternative_stream = @stream.alternative_stream
  end

  def show
    @more_pictures_path = new_pictures_slideshow_path
  end

  def faves
    @more_pictures_path = fave_pictures_slideshow_path
  end

  def fave_pictures
    render_json_pictures Picture.faved_by(current_collector, params[:min_rating].to_i, params[:page].to_i,  params[:num].to_i)
  end

  def new_pictures
    exclude_ids =  params[:exclude_ids].present? ? params[:exclude_ids].map(&:to_i) : []
    num_of_pictures = params[:num].to_i
    new_pictures = Picture.new_pictures_by(current_collector, num_of_pictures, *exclude_ids)

    render_json_pictures(new_pictures)
  end


end