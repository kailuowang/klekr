require File.expand_path('../slideshow_page', __FILE__)

module Functional
  class FavePage < SlideshowPage
    def open opts = {}
      super('slideshow/faves', true, opts)
    end

    def just_faved? pic_src
      enter_slide_mode
      slide_picture['src'] == pic_src
    end

  end
end