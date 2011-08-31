module Collectr
  class Editor

    def initialize
      @editor_collector = Collector.where(user_id: Settings.editor_userid).first if Settings.editor_userid
    end

    def ensure_editor_collector
      raise 'editor_userid must be set in settings' if Settings.editor_userid.blank?
      @editor_collector ||= Collector.find_or_create(user_id: Settings.editor_userid, user_name: Settings.editor_name)
    end

    def ready?
      @editor_collector.present?
    end

    def editor_streams
       [collection_stream = FlickrStream.find_or_create(
         editor_collection_stream_opts.merge(collector: @editor_collector)
       )] + editor_high_rating_streams
    end

    def editorial_collection_stream_for(collector)
      stream = FlickrStream.find_or_create(
         editor_collection_stream_opts.merge(collector: collector, collecting: true)
      )
      stream.sync(1.month.ago, 40)
      stream
    end



    def recommendation_streams_for(collector)
      [editorial_collection_stream_for(collector)] + create_recommendation_streams_for(collector)
    end

    private
    def editor_collection_stream_opts
      {
        user_id: @editor_collector.user_id,
        username: @editor_collector.user_name,
        type: FaveStream.name
      }
    end
    def create_recommendation_streams_for(collector)
      editor_high_rating_streams.map do |editor_stream|
        FlickrStream.find_or_create(
          user_id: editor_stream.user_id,
          username: editor_stream.username,
          type: editor_stream.type,
          collecting: true,
          collector: collector
        )
      end
    end

    def editor_high_rating_streams
      @editor_collector.flickr_streams.select do |stream|
        stream.star_rating > 3
      end
    end

    def editor_collector
      @editor_collector
    end
  end
end