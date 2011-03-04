
class UploadStream < FlickrStream
  sync_uses flickr.people, :getPhotos, :min_upload_date

  def stream_url
    user_url
  end

end