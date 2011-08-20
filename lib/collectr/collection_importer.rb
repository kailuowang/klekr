module Collectr
  class CollectionImporter
    def initialize(collector)
      @collector = collector
    end

    def import
      stream = FlickrStream.build_type(user_id: @collector.user_id,
                                       username: @collector.user_name,
                                       user_url: 'N/A',
                                       collector: @collector,
                                       type: 'FaveStream')
      stream.get_pictures(10,1)
    end

  end
end