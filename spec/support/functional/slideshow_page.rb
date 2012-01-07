module Functional
  class SlideshowPage
    INTERVAL = 0.1

    def initialize
      @d = Selenium::WebDriver.for :firefox
      @d.manage.window.size = Selenium::WebDriver::Dimension.new(1024, 768)
      @d.manage.timeouts.implicit_wait = 10
      @w = Selenium::WebDriver::Wait.new(timeout: 10, interval: INTERVAL)
    end

    def open page = 'slideshow', grid_default = false
      @d.get "http://localhost:3000/#{page}"
      wait_until do
        if(grid_default)
          wait_until_grid_shows
        else
          wait_until_slide_shows
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

    def set_fave_rating rating
      @d["ratingDisplay-#{rating}"].click
    end

    def set_option options
      @d["option-button"].click
      if(options[:rating].present?)
        select = Selenium::WebDriver::Support::Select.new(@d['rating-filter-select'])
        select.select_by(:index, options[:rating] - 1)
      end
      @d['close-options-button'].click
      wait_until_grid_shows
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

    def fave rating = 1
      fave_button.click
      fave_rating_star(rating).click
      wait_until do
        unfave_button.displayed?
      end
    end

    def unfave
      unfave_button.click
      wait_until do
        fave_button.displayed?
      end
    end

    def highlighted_grid_picture
      s ".grid-picture.highlighted"
    end

    def highlighted_grid_picture_id
      grid_pic_id highlighted_grid_picture
    end

    def grid_pictures
      @d.find_elements css: ".grid-picture"
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

    def enter_slide_mode
      highlighted_grid_picture.click
      wait_until_slide_shows
    end

    def grid_next_page
      click_right_button
      wait_until_grid_shows
    end

    def wait_until_grid_shows
      wait_until do
        grid_pictures.select(&:displayed?).present?
      end
    end

    def wait_until_slide_shows
      wait_until do
        slide_picture.displayed?
      end
    end

    def wait_until_fave_ready
       wait_until do
        fave_button.displayed? || unfave_button.displayed?
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