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
    @advance_by_progress = true #contrast to progress by paging
    @more_pictures_path = new_pictures_slideshow_path
  end

  def faves
    @more_pictures_path = fave_pictures_slideshow_path
  end

  def fave_pictures
    render_json_pictures current_collector.collection( params[:num].to_i, params[:page].to_i, params.slice(:min_rating))
  end

  def new_pictures
    exclude_ids =  params[:exclude_ids].present? ? params[:exclude_ids].map(&:to_i) : []
    per_page = params[:num].to_i
    page = params[:page].to_i
    new_pictures = Collectr::PictureRepo.new(current_collector).new_pictures(*exclude_ids).paginate(page: page , per_page: per_page)

    render_json_pictures(new_pictures)
  end


end