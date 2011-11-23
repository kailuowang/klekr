
class UploadStream < FlickrStream
  include Collectr::Flickr
  sync_uses module: :people, method: :getPhotos, time_field: :upload_date

  def stream_url
    user_url
  end


  def type_display
    "Works"
  end

end