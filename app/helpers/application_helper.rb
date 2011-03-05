module ApplicationHelper
  def window_size
    cookies[:window_size].try(:to_sym)
  end

  def picture_tag picture, size
    link_to image_tag(picture.flickr_url(size)), picture.url
  end
end
