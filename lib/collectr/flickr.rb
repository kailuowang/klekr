module Collectr::Flickr
  def flickr(for_collector = nil)
    for_collector ||= respond_to?(:collector) ? collector : Thread.current[:current_collector]

    @flickr ||= FlickRaw::Flickr.new(for_collector.try(:auth_token))
  end
end
