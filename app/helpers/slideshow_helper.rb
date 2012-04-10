module SlideshowHelper
  def picture_url picture, context
    context + "#slide-0-#{picture.id}"
  end

  def render_bottom_link(link_name)
    case link_name
      when :editors_choice_rss
         link_to (image_tag('feed-icon-small.png', class: 'rss-icon') + " RSS").html_safe, editors_choice_path(format: :rss)
      when :editors_choice
        link_to "Editor's Choice" , editors_choice_path
      when :editor_choice_google_currents
        google_currents_link()
      else
        ''
    end
  end

  def google_currents_link
    link_to(image_tag('google-currents-logo-small.png', class: 'currents-logo'), "http://www.google.com/producer/editions/CAow2Y0b/klekr")
  end
end