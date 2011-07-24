module Collectr
  module PictureData
    def data_for(picture)
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


    def data_list_for(pictures)
      pictures.map do |picture|
        data_for(picture)
      end
    end


  end
end