class PicturesController < ApplicationController
  include Collectr::PictureControllerHelper

  before_filter :authenticate, :load_picture

  #PUT /pictures/1/fave
  def fave
    @picture.get_viewed
    @picture.fave(params[:rating].to_i)
    js_ok
  end

 #PUT /pictures/1/unfave
  def unfave
    @picture.unfave
    js_ok
  end

  #PUT /pictures/1/viewed
  def viewed
    @picture.get_viewed
    js_ok
  end

  def resync
    @picture.resync
    render :json => data_for(@picture)
  end

  def all_viewed
    Picture.find(params[:ids]).each do |p|
      check_picture_access p
      p.get_viewed
    end
    js_ok
  end

  #GET /pictures
  def index
    redirect_to slideshow_path
  end

  #GET /pictures/1
  def show
    respond_to do |format|
      format.html { redirect_to action: :show, controller: :slideshow, id: params[:id] }
      format.json do
        picture = Picture.find(params[:id])
        render :json => data_for(picture)
      end
    end
  end
                                                      ``
  private
  def load_picture
    @picture = Collectr::PictureRepo.new(current_collector).find(params[:id]) if params[:id].present?
    check_picture_access(@picture)
  end

  def check_picture_access picture
    if(current_collector && picture && picture.collector != current_collector)
      raise ActionController::RoutingError.new('Access not permitted')
    end
  end

end
