class SlideshowController < ApplicationController
  before_filter :authenticate

  def  show
  end


  def current
    respond_to do |f|
      f.js { render :json => picture_data( Picture.most_interesting_for(current_collector ) ) }
    end
  end

  def pictures_after
    target_picture = Picture.find(params[:target_picture])
    num_of_pictures = params[:num].to_i
    new_pictures = target_picture.next_new_pictures(num_of_pictures)

    respond_to do |f|
      f.js { render :json => pictures_data(new_pictures) }
    end
  end

  private

  def pictures_data(pictures)
    pictures.map do |picture|
      picture_data(picture)
    end
  end

  def picture_data(picture)
    {
      :large_url => picture.large_url,
      :medium_url => picture.medium_url,
      :next_pictures_path => slideshow_pictures_after_path + "?target_picture=#{picture.id}&num=",
      :interestingess => picture.stream_rating.to_i

    }
  end



end