
class UploadStream < FlickrStream
  include Collectr::Flickr
  sync_uses :people, :getPhotos, :upload_date

  def stream_url
    user_url
  end


  def type_display
    "Works"
  end

end