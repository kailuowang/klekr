module Functional
  class SlideshowPage < PageBase

    def open page = 'slideshow', grid_default = false, opts = {}
      super(page, opts)
      wait_until do
        if (grid_default)
          wait_until_grid_shows
        else
          wait_until_slide_shows
        end
      end
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
      set_form_in_gallery_option(options)
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
      click_direction_button('right')
    end

    def click_left_button
      click_direction_button('left')
    end

    def click_direction_button(direction)
      url = @d.current_url
      button = direction_button(direction)
      wait_until do
        button.displayed?
      end
      button.click
      pause 0.05
    end

    def direction_button(direction)
      s "##{direction}Arrow"
    end

    def left_arrow
      s '#leftArrow'
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
      last_index = grid_pictures_ids.count - 1
      s ".grid-picture.grid-index-#{last_index}"
    end

    def grid_pictures_ids
      grid_pictures.map {|gp| grid_pic_id(gp)}
    end

    def enter_grid_mode
      click_slide_picture
      wait_until_grid_shows
    end

    def click_slide_picture
      wait_until do
        slide_picture_ready?
      end
      slide_picture.click
    end

    def slide_picture_ready?
      slide_picture.displayed? and slide_picture.size.height.to_i > 10
    end

    def enter_slide_mode
      wait_until { highlighted_grid_picture.present? }
      highlighted_grid_picture.click
      wait_until_slide_shows
    end

    def grid_next_page
      old_id = highlighted_grid_picture_id
      click_right_button
      wait_until_grid_shows
      wait_until do
        highlighted_grid_picture_id != old_id
      end

    end

    def wait_until_grid_shows
      wait_until do
        @d['gridPictures'].displayed? || empty_message_shows
      end
    end

    def wait_until_slide_shows
      wait_until do
        ( slide_picture_ready? && !loading_slide_picture? ) || empty_message_shows
      end
    end

    def loading_slide_picture?
      slide_picture['src'].include?('loading')
    end

    def empty_message_shows
      s('#empty-gallery-message').displayed?
    end

    def wait_until_fave_ready
      wait_until do
        fave_button.displayed? || unfave_button.displayed?
      end
    end

    def fave_login_link
      s '#fave-login'
    end

    def click_fave_login
      wait_until { fave_login_link.displayed? }
      fave_login_link.click
    end

    private

    def set_form_in_gallery_option(options)
      if (options[:rating].present?)
        select = Selenium::WebDriver::Support::Select.new(@d['rating-filter-select'])
        select.select_by(:index, options[:rating] - 1)
      end
      if options[:faved_at_max].present?
        @d['fave-at-date'].send_keys(options[:faved_at_max])
      end
      if options[:faved_at_min].present?
        @d['fave-at-date-after'].send_keys(options[:faved_at_min])
      end
      @d['viewed-filter-checkbox'].click if options[:viewed_filter]
      @d['type-filter-checkbox'].click if options[:type_filter]
    end

    def grid_pic_id grid_picture_element
      grid_picture_element['id'].split('-')[1]
    end

  end
end