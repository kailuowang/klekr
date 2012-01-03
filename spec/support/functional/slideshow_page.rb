module Functional
  class SlideshowPage
    INTERVAL = 0.1

    def initialize
      @d = Selenium::WebDriver.for :firefox
      @d.manage.window.size = Selenium::WebDriver::Dimension.new(1024, 768)
      @d.manage.timeouts.implicit_wait = 4
      @w = Selenium::WebDriver::Wait.new(timeout: 4, interval: INTERVAL)
    end

    def open
      @d.get "http://localhost:3000/slideshow"
      wait_until do
        slide_picture.displayed?
      end
    end

    def close
      @d.quit
    end

    def slide_picture
      @d["picture"]
    end

    def click_right_button
      @d['right'].click
      pause
    end

    def click_left_button
      @d['left'].click
      pause
    end

    def left_arrow
      s '#leftArrow'
    end

    def pause secs = 0.4
      count = 0
      wait_until do
        (count += 1) * INTERVAL > secs
      end
    end

    def highlighted_grid_picture
      s ".grid-picture.highlighted"
    end

    def grid_pictures
      s ".grid-picture"
    end

    def last_grid_picture
      s ".grid-picture.grid-index-5"
    end

    def grid_pictures_ids
      grid_pictures.map {|gp| gp['id']}
    end

    def s selector
      results = @d.find_elements css: selector
      if(results.count > 1)
        results
      else
        results.first
      end
    end
    def wait_until(&block)
      @w.until &block
    end

  end
end