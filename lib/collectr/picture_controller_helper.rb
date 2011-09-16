module Collectr
  module PictureControllerHelper
    def data_for(picture)
      {
        id:               picture.string_id,
        largeUrl:         picture.large_url,
        mediumUrl:        picture.medium_url,
        smallUrl:         picture.small_url,
        interestingness:  picture.stream_rating.to_i,
        title:            picture.title,
        flickrPageUrl:    picture.url,
        ownerName:        picture.owner_name,
        faved:            picture.faved?,
        rating:           picture.rating,
        viewed:           picture.viewed?,
        collected:        !picture.new_record? && picture.collected?,
        ownerPath:        user_path(picture.owner_id),
        fromStreams:      picture.flickr_streams.map do |stream|
                            data_for_stream_info(stream)
                          end
      }.merge action_paths_for(picture)
    end

    def action_paths_for(picture)
      {}.tap do |h|
        h[:getViewedPath]    =      viewed_picture_path(picture) unless picture.new_record?
        h[:getAllViewedPath] =      all_viewed_pictures_path
        h[:favePath]         =      fave_picture_path(picture.string_id)
        h[:unfavePath]       =      unfave_picture_path(picture.string_id)
      end
    end

    def data_list_for(pictures)
      pictures.map do |picture|
        data_for(picture)
      end
    end

    def render_json_pictures(pictures)
      render_json data_list_for(pictures)
    end

    private
    def data_for_stream_info(stream)
      { username: stream.username, type: stream.type_display, path: flickr_stream_path(stream)}
    end

  end
end