class PicturesController < ApplicationController
  include ApplicationHelper

  before_filter :login_required
   # GET /pictures/1
  # GET /pictures/1.xml
  def show
    @picture = Picture.find(params[:id])
    @default_pic_url = window_size == :large ? @picture.large_url : @picture.medium_url
    preload_pics_according_to_window_size
    @hidden_treasure = params[:hidden_treasure].present?
    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @picture }
    end
  end



  # DELETE /pictures/1
  # DELETE /pictures/1.xml
  def destroy
    @picture = Picture.find(params[:id])
    @picture.destroy

    respond_to do |format|
      format.html { redirect_to(pictures_url) }
      format.xml  { head :ok }
    end
  end

  #PUT /pictures/1/fave
  def fave
    @picture = Picture.find(params[:id])
    @picture.fave
    respond_to do |format|
      format.html { redirect_to(:back, notice: "Faved!") }
      format.xml  { head :ok }
    end
  end

  #GET /pictures/slide_show
  def slide_show
    @picture = Picture.desc.find_by_viewed(false)

    if @picture
      redirect_to @picture
    else
      redirect_to flickr_streams_path, notice: "You have no unviewed pictures, please sync your subscriptions from here."
    end

  end

  #GET /pictures/1/next
  def next
    pic = Picture.find(params[:id])
    pic.get_viewed

    next_pic = params[:hidden_treasure].present? ? pic.guess_hidden_treasure : pic.next_new_pictures(1).first
    path = next_pic ? picture_path(id: next_pic.id, hidden_treasure: params[:hidden_treasure]) : slide_show_pictures_path
    redirect_to( path )
  end

  #GET /pictures
  def index
    slide_show
  end

  private

  def preload_pics_according_to_window_size
    case window_size
      when :large
        preload_pics(:large, 6)
        preload_pics(:medium, 2)
      else
        preload_pics(:medium, 10)
        preload_pics(:large, 3)
    end
  end

  def preload_pics size, num
    @pictures_to_cache ||= []
    @pictures_to_cache += @picture.next_new_pictures(num).map do |pic|
      pic.flickr_url(size)
    end
  end
end
