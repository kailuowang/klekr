module Functional
  class PageBase
    INTERVAL = 0.1

    def initialize
      @d = Selenium::WebDriver.for :firefox
      @d.manage.window.size = Selenium::WebDriver::Dimension.new(1024, 768)
      @d.manage.timeouts.implicit_wait = 30
      @w = Selenium::WebDriver::Wait.new(timeout: 30, interval: INTERVAL)
    end

    def open page
      @d.get "http://localhost:3000/#{page}"
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

    def wait_until(&block)
      @w.until &block
    end

    def hove_on(element)
      @d.action.move_to(element).perform
      pause 0.5
    end

    protected

    def s selector
      results = ss selector
      if(results.count > 1)
        results
      else
        results.first
      end
    end

    def ss selector
      @d.find_elements css: selector
    end

  end
end