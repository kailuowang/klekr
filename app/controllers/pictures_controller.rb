class PicturesController < ApplicationController
  include Collectr::PictureControllerHelper

  before_filter :load_picture, except: [:resync, :show]
  before_filter :authenticate, except: [:resync, :show]
  before_filter :load_picture_anonymously, only: [:resync, :show]

  #PUT /pictures/1/fave
  def fave
    @picture.get_viewed
    new_rating = params[:rating].present? ? params[:rating].to_i : 1
    @picture.fave(new_rating)
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
    @picture.resync unless params[:skip_flickr_resync]
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
    render_json(data_for(@picture))
  end

  private

  def load_picture
    @picture = Collectr::PictureRepo.new(current_collector).find(params[:id]) if params[:id].present?
    check_picture_access(@picture)
  end

  def load_picture_anonymously #if possible
    id = params[:id]
    if Picture.is_flickr_id?(id) || current_collector.present?
      authenticate
      load_picture
    else
      @picture = Picture.find(params[:id])
    end
  end

  def check_picture_access picture
    if(current_collector && picture && picture.collector != current_collector)
      raise ActionController::RoutingError.new('Access not permitted')
    end
  end

end
