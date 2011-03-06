class FaveStream < FlickrStream
  sync_uses flickr.favorites, :getList, :min_fave_date

  def stream_url
    user_url + "favorites/?view=md"
  end

  def type_display
    "Faves"
  end
end
