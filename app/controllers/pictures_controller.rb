class PicturesController < ApplicationController
  include Collectr::PictureControllerHelper

  before_filter :authenticate

  #PUT /pictures/1/fave
  def fave
    @picture = Picture.find(params[:id])
    @picture.get_viewed
    @picture.fave(params[:rating].to_i)
    respond_to do |format|
      format.js  { render :json => {} }
    end
  end

  #GET /pictures/current
  def current
    respond_to do |f|
      f.js { render :json => data_for( Picture.most_interesting_for(current_collector ) ) }
    end
  end

  #PUT /pictures/1/viewed
  def viewed
    Picture.find(params[:id]).get_viewed
    respond_to do |format|
      format.js  { render :json => {} }
    end
  end

  #GET /pictures
  def index
    redirect_to slideshow_path
  end

  #GET /pictures/1
  def show
    respond_to do |format|
      format.html { redirect_to action: :show, controller: :slideshow, id: params[:id] }
      format.js do
        picture = Picture.find(params[:id])
        render :json => data_for(picture)
      end
    end
  end


end
