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
        rating: stream.star_rating,
        subscribed: stream.collecting
      }
    end

    def find_stream(stream_user_id = params[:user_id])
      FlickrStream.find_or_create(user_id: stream_user_id, collector: collector_for_stream, type: params[:type])
    end

    def collector_for_stream
      current_collector || Collectr::Editor.new.ensure_editor_collector
    end

  end

end