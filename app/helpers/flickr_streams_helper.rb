module FlickrStreamsHelper
  def rating_display flickr_stream
    rating = flickr_stream.rating
    "%0.2f" % rating if rating > 0
  end
end
