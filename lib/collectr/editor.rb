module Collectr
  class Editor


    def initialize
      @editor_collector = Collector.where(user_id: editor_user_id).first if editor_user_id
    end

    def ensure_editor_collector
      raise 'editor_userid must be set in settings' if editor_user_id.blank?
      @editor_collector ||= Collector.find_or_create(user_id: editor_user_id,
                                                     user_name: Settings.editor_name,
                                                     access_toke: Collectr::FlickrConfig['editor_user_access_token'],
                                                     access_secret: Collectr::FlickrConfig['editor_user_access_secret'])
    end

    def ready?
      @editor_collector.present?
    end

    def is_editor(collector)
      collector.user_id == editor_user_id
    end

    def editorial_collection_stream_for(collector)
      stream = FlickrStream.find_or_create(
        editor_collection_stream_opts.merge(collector: collector)
      )
      stream
    end

    def recommendation_streams_for(collector)
      [editorial_collection_stream_for(collector)] + create_recommendation_streams_for(collector)
    end

    private

    def editor_user_id
      Settings.editor_userid
    end

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
          collector: collector
        )
      end
    end

    def editor_high_rating_streams
      @editor_collector.flickr_streams.includes(:monthly_scores).select do |stream|
        stream.star_rating > 3
      end
    end

    def editor_collector
      @editor_collector
    end
  end
end