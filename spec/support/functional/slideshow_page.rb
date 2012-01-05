module Functional
  class SlideshowPage
    INTERVAL = 0.1

    def initialize
      @d = Selenium::WebDriver.for :firefox
      @d.manage.window.size = Selenium::WebDriver::Dimension.new(1024, 768)
      @d.manage.timeouts.implicit_wait = 4
      @w = Selenium::WebDriver::Wait.new(timeout: 4, interval: INTERVAL)
    end

    def open page = 'slideshow', grid_default = false
      @d.get "http://localhost:3000/#{page}"
      wait_until do
        if(grid_default)
          highlighted_grid_picture.present? && highlighted_grid_picture.displayed?
        else
          slide_picture.displayed?
        end
      end
    end

    def close
      @d.quit
    end

    def fave_button
      @d['faveLink']
    end

    def unfave_button
      @d['removeFaveLink']
    end


    def fave_rating_star rating = 1
      @d["faveRating-#{rating}"]
    end

    def slide_picture
      @d["picture"]
    end

    def slide_picture_id
      slide_picture['data-pic-id']
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

    def highlighted_grid_picture_id
      grid_pic_id highlighted_grid_picture
    end

    def grid_pictures
      s ".grid-picture"
    end

    def last_grid_picture
      s ".grid-picture.grid-index-5"
    end

    def grid_pictures_ids
      grid_pictures.map {|gp| grid_pic_id(gp)}
    end

    def enter_grid_mode
      slide_picture.click
      wait_until_grid_shows
    end

    def grid_next_page
      click_right_button
      wait_until_grid_shows
    end

    def wait_until_grid_shows
      wait_until do
        grid_pictures.select(&:displayed?)
      end
    end

    private

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

    def grid_pic_id grid_picture_element
      grid_picture_element['id'].split('-')[1]
    end

  end
end