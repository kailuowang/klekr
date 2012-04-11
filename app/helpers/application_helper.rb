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
    style_class = path != request.env['PATH_INFO'] ? 'navigation-link' : 'navigation-link current'
    
    link_to name, path, class: style_class      
  end

  def render_navigation_links()
    if @navigation_options.present?
      @navigation_options.map do |option|
        navigation_link(option[:name], option[:path])
      end.compact.join.html_safe
    end
  end

  def icon(with_icon)
    icon_url = with_icon.respond_to?(:icon_url) ? with_icon.icon_url : with_icon
    render partial: '/general/icon', locals: {icon_url: icon_url} if icon_url.present?
  end

  def restful_flickr_stream_path stream
    find_flickr_streams_path(user_id: stream.user_id, type: stream.type)
  end
end
