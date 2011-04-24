class FaveStream < FlickrStream
  include Collectr::Flickr
  sync_uses :favorites, :getList, :min_fave_date

  def stream_url
    user_url + "favorites/?view=md"
  end

  def type_display
    "Faves"
  end
end
