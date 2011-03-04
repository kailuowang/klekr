class PicturesController < ApplicationController
  include ApplicationHelper

   # GET /pictures/1
  # GET /pictures/1.xml
  def show
    @picture = Picture.find(params[:id])
    @picture.update_attribute(:viewed, true) unless @picture.viewed?

    @pictures_to_cache = @picture.next_new_pictures(5).map do |pic|
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

  #GET /slide_show_pictures
  def slide_show
    @picture = Picture.desc.find_by_viewed(false)
    redirect_to @picture
  end

end
