class PicturesController < ApplicationController
  include Collectr::PictureData

  before_filter :authenticate


  #PUT /pictures/1/fave
  def fave
    @picture = Picture.find(params[:id])
    @picture.get_viewed
    @picture.fave
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


end
