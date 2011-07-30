module Collectr
  module PictureControllerHelper
    def data_for(picture)
      {
        id:               picture.id || picture.url,
        largeUrl:         picture.large_url,
        mediumUrl:        picture.medium_url,
        interestingness:  picture.stream_rating.to_i,
        title:            picture.title,
        flickrPageUrl:    picture.url,
        ownerName:        picture.owner_name,
        faved:            picture.faved?,
        ownerPath:        stream_user_path(picture.pic_info.owner, type: 'UploadStream'),
        fromStreams:      picture.flickr_streams.map do |stream|
                            data_for_stream(stream)
                          end
      }.merge action_paths_for(picture)
    end

    def action_paths_for(picture)
      picture.new_record? ? {} :
        {
          getViewedPath:    viewed_picture_path(picture),
          favePath:         fave_picture_path(picture)
        }
    end

    def data_for_stream(stream)
      { username: stream.username, type: stream.type_display, path: stream_user_path(stream.user_id, type: stream.type)}
    end


    def data_list_for(pictures)
      pictures.map do |picture|
        data_for(picture)
      end
    end


    def render_json_pictures(pictures)
      render_json data_list_for(pictures)
    end

  end
end