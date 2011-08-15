class FaveStream < FlickrStream
  include Collectr::Flickr
  sync_uses :favorites, :getList, :fave_date

  def stream_url
    user_url + "favorites/?view=md"
  end

  def type_display
    "Collection"
  end
end
