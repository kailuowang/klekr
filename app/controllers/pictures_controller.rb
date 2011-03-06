class PicturesController < ApplicationController
  include ApplicationHelper

   # GET /pictures/1
  # GET /pictures/1.xml
  def show
    @picture = Picture.find(params[:id])
    @picture.update_attribute(:viewed, true) unless @picture.viewed?
    @default_pic_url = window_size == :large ? @picture.large_url : @picture.medium_url
    preload_pics_according_to_window_size

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
    redirect_to @picture
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
