module Functional
  class PageBase
    INTERVAL = 0.01

    def initialize
      @d = Selenium::WebDriver.for :chrome
      @d.manage.timeouts.implicit_wait = 0.5
      @w = Selenium::WebDriver::Wait.new(timeout: 4, interval: INTERVAL)
    end

    def open page, opts = {}
      params = if opts.present?
        '?' + opts.map { |k, v| "#{k}=#{v}" }.join('&')
      end
      @d.get "http://localhost:3000/#{page}#{params}"
    end

    def close
      @d.quit
    end

    def pause secs = 0.4
      count = 0
      wait_until do
        (count += 1) * INTERVAL > secs
      end
    end

    def log_out
      user_link = s('#top-banner #user-name.dropdown-toggle')
      if user_link
        user_link.click
        s('#sign-out-link').click
        s('#bye-bye')
      end
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

    def s selector
      results = ss selector
      if(results.count > 1)
        results
      else
        results.first
      end
    end

    protected

    def ss selector
      @d.find_elements css: selector
    end

  end
end