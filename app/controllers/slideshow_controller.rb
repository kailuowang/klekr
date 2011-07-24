class SlideshowController < ApplicationController
  before_filter :authenticate

  def  show
  end


  def current
    respond_to do |f|
      f.js { render :json => picture_data( Picture.most_interesting_for(current_collector ) ) }
    end
  end

  def new_pictures
    exclude_ids = params[:exclude_ids].map(&:to_i)
    num_of_pictures = params[:num].to_i
    new_pictures = Picture.new_pictures_by(current_collector, num_of_pictures, exclude_ids)

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
      id:               picture.id,
      largeUrl:         picture.large_url,
      mediumUrl:        picture.medium_url,
      interestingness:  picture.stream_rating.to_i,
      getViewedPath:    viewed_picture_path(picture),
      title:            picture.title,
      flickrPageUrl:    picture.url,
      ownerName:        picture.owner_name,
      ownerPath:        user_path(picture.pic_info.owner),
      faved:            picture.faved?,
      favePath:         fave_picture_path(picture),
      fromStreams:      picture.flickr_streams.map do |stream|
                          { username: stream.username, type: stream.type_display, path: user_path(stream.user_id)}
                        end
    }
  end



end