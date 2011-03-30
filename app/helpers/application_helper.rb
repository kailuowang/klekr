module ApplicationHelper
  def window_size
    cookies[:window_size].try(:to_sym) || :medium
  end

  def picture_tag picture, size
    path = picture.new_record? ? picture.url : picture_path(picture)
    link_to image_tag(picture.flickr_url(size)), path
  end


  def rating_display flickr_stream
    "#{flickr_stream.star_rating}/5"
  end

  def format_float f
    f.present? ? "%0.2f" % f : '0'
  end

end
