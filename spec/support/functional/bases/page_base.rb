module Functional
  class PageBase
    INTERVAL = 0.01

    def initialize
      @d = Selenium::WebDriver.for :chrome, profile: chrome_size_profile
      @w = Selenium::WebDriver::Wait.new(timeout: 10, interval: INTERVAL)
    end

    def chrome_size_profile
      profile = Selenium::WebDriver::Chrome::Profile.new
      profile['browser.window_placement.top'] = 0
      profile['browser.window_placement.left'] = 0
      profile['browser.window_placement.right'] = 1024
      profile['browser.window_placement.bottom'] = 800
      profile
    end

    def capture_screen filename
      path = File.expand_path("../../../../../tmp/screenshots/#{filename}.png", __FILE__)
      @d.save_screenshot(path)
    end

    def open page, opts = {}
      params = if opts.present?
        '?' + opts.map { |k, v| "#{k}=#{v}" }.join('&')
      end
      get("#{page}#{params}")
    end

    def get(path)
      @d.get "http://localhost:3000/#{path}"
    end

    def close
      if(js_error.present?)
        throw "Won't Close Browser Because Javascript Error Occurred: " + js_error
      end
      @d.quit
    end

    def pause secs = 0.4
      count = 0
      wait_until do
        (count += 1) * INTERVAL > secs
      end
    end

    def log_in
      get('flickr_streams') #temporary solution, go to the my sources page and take advantage of the auto login
    end

    def log_out
      ul = user_link
      if ul
        ul.click
        s('#sign-out-link').click
        s('#bye-bye')
      end
    end

    def user_link
      s('#top-banner #user-name.dropdown-toggle')
    end

    def logged_in?
      user_link && user_link.displayed?
    end

    def refresh
      @d.navigate.refresh
    end

    def wait_until(&block)
      @w.until &block
    end

    def hove_on(element)
      @d.action.move_to(element).perform
      pause 0.5
    end

    def total_new_pictures
      @d['user-name'].click
      count_identifier = '#user-dropdown #new-pictures-count'
      wait_until do
        count_text = s(count_identifier).text
        count_text.present? && count_text != '...'
      end
      s(count_identifier).text
    end

    def f selector
      wait_until do
        @d.find_element css: selector
      end
    end

    def s selector
      results = ss selector
      if(results.count > 1)
        results
      else
        results.first
      end
    end

    def js_error
      s("body")["data-JSError"];
    end

    protected

    def ss selector
      @d.find_elements css: selector
    end

  end
end