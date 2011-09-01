module Collectr
  module FlickrStreamsControllerHelper

    def data_for_streams(streams)
      streams.map do |stream|
        {
            id: stream.id,
            iconUrl: stream.icon_url,
            ownerName: stream.username,
            type: stream.type_display,
            slideUrl: flickr_stream_path(stream),
            rating: stream.star_rating
        }
      end
    end
  end
end