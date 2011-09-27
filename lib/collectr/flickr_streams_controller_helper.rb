module Collectr
  module FlickrStreamsControllerHelper

    def data_for_streams(streams)
      streams.map do |stream|
        data_for_stream(stream)
      end
    end

    def data_for_stream(stream)
      {
        id: stream.id,
        iconUrl: stream.icon_url,
        username: stream.username,
        user_id: stream.user_id,
        type: stream.type,
        typeDisplay: stream.type_display,
        slideUrl: flickr_stream_path(stream),
        rating: stream.star_rating
      }
    end
  end
end