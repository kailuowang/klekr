module Collectr::Flickr
  def flickr(for_collector = nil)
    for_collector ||= respond_to?(:collector) ? collector : Thread.current[:current_collector]

    @flickr ||= FlickRawFactory.create(for_collector.try(:auth_token))
  end

  #since merely mentioning the FlickrRaw::Flickr class will cause a call to the flickr server
  class FlickRawFactory

    def self.create(token)
      FlickRaw::Flickr.new(token)
    end
  end
end

