module Collectr::Flickr
  @flickr
  def flickr
    current_collector = Thread.current[:current_collector]
    @flickr ||= FlickRaw::Flickr.new(current_collector.auth_token)
  end
end