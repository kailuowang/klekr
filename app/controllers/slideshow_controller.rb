class SlideshowController < ApplicationController
  before_filter :authenticate

  def  show
  end


  def current
    respond_to do |f|
      f.js {render :json => picture_data(current_picture) }
    end
  end

  private

  def current_picture
    Picture.desc.collected_by(current_collector).unviewed.first
  end

  def picture_data(picture)
    {:large_url => picture.large_url}
  end

end