module Collectr::Flickr
  def flickr(for_collector = nil)
    for_collector ||= self.collector if self.respond_to?(:collector)
    FlickRawFactory.create(for_collector.try(:access_token), for_collector.try(:access_secret))
  end

  def try_flickr(msg = 'failed to do flickr request')
    begin
      yield
    rescue FlickRaw::FailedResponse => e
      Rails.logger.error(msg + ' ' + e.inspect)
    end
  end

  #since merely mentioning the FlickrRaw::Flickr class will cause a call to the flickr server
  class FlickRawFactory
    def self.create(token, secret)
      flickr = FlickRaw::Flickr.new
      flickr.access_token = token
      flickr.access_secret = secret
      flickr
    end
  end
end

