class PicturesController < ApplicationController
  include ApplicationHelper
  # GET /pictures
  # GET /pictures.xml
  def index
    @pictures = Picture.all

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @pictures }
    end
  end

  # GET /pictures/1
  # GET /pictures/1.xml
  def show
    @picture = Picture.find(params[:id])
    @next3pictures = [@picture.previous.flickr_url(picture_show_size),
                      @picture.previous.previous.flickr_url(picture_show_size),
                      @picture.previous.previous.previous.flickr_url(picture_show_size)]
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
end
