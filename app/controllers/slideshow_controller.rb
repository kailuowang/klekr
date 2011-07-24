class SlideshowController < ApplicationController
  include Collectr::PictureData
  before_filter :authenticate

  def show
    @first_picture_path = current_pictures_path
    @new_pictures_path = new_pictures_slideshow_path
  end


  def new_pictures
    exclude_ids = params[:exclude_ids].map(&:to_i)
    num_of_pictures = params[:num].to_i
    new_pictures = Picture.new_pictures_by(current_collector, num_of_pictures, exclude_ids)

    respond_to do |f|
      f.js { render :json => data_list_for(new_pictures) }
    end
  end


end