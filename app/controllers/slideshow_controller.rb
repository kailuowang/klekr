class SlideshowController < ApplicationController
  before_filter :authenticate

  def  show
  end

  def current
    respond_to do |f|
      f.js {render :json => { :large_url => current_picture.large_url, :next_picture_path => "google" } }
    end
  end

  private

  def current_picture
    Picture.desc.collected_by(current_collector).unviewed.first
  end

end