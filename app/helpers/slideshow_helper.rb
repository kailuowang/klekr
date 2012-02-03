module SlideshowHelper
  def picture_url picture, context
    context + "#slide-0-#{picture.id}"
  end
end