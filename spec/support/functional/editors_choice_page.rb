require File.expand_path('../slideshow_page', __FILE__)

module Functional
  class EditorsChoicePage < SlideshowPage
    def open opts = {}
      super('editors_choice', true, opts)
      f('#exhibit-name')
      wait_until_grid_shows
    end
  end
end