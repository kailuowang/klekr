module ApplicationHelper

  def rating_display flickr_stream
    "#{flickr_stream.star_rating}/5"
  end

  def format_float f
    f.present? ? "%0.2f" % f : '0'
  end

  def hidden_class hide
    hide ? 'hidden' : ''
  end

  def navigation_link name, path
    if path != request.env['PATH_INFO']
      link_to name, path
    end
  end

  def navigation_links(links)
    links.map{|name, path| navigation_link(name, path)}.compact.join(' | ').html_safe
  end

end
