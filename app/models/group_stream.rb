class GroupStream < FlickrStream
  include Collectr::Flickr
  sync_uses module: [:groups, :pools], method: :getPhotos, id_field: :group_id

  def stream_url
    "#{user_url}pool/"
  end

  def type_display
    "Group"
  end

  def to_s
    "#{type_display} #{username}"
  end

  def alternative_stream
    nil
  end

  def user_url
    "http://www.flickr.com/groups/#{user_id}/"
  end
end
