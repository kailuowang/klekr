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
    @pictures_to_cache = @picture.previous_pictures(5).map do |pic|
      [pic.large_url, pic.medium_url]
    end.flatten

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
