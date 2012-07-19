module Collectr
  module TestDataUtil
    def test_collector
      @test_collector ||= ::Collector.find_or_create(
                                  user_id: flickr_config['test_user_id'],
                                  user_name: flickr_config['test_user_name'],
                                  access_token: flickr_config['test_access_token'],
                                  access_secret: flickr_config['test_access_secret'])
    end

    def dev_collector
      @dev_collector ||= ::Collector.find_or_create(user_id: flickr_config['user_id'],
                                 user_name: flickr_config['user_name'],
                                 access_token: flickr_config['access_token'],
                                 access_secret: flickr_config['access_secret'])
    end

    private
    def flickr_config
      Collectr::FlickrConfig
    end
  end
end
