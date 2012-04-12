require File.expand_path('../slideshow_page', __FILE__)

module Functional
  class FlickrStreamSlidePage < SlideshowPage

    def open(url, opts = {})
      super(url, true, opts)
    end

    def open_anonymously(stream, opts = {})
      open("flickr_streams/find", opts.merge(user_id: stream.user_id, type: stream.type) )
    end

    def open_authenticated(stream_id, opts ={})
      open("flickr_streams/#{stream_id}", opts)
    end

    def open_by_user(user_id, opts = {})
      open("users/#{user_id}", opts)
    end

    def subscribe
      logged_in = subscribe_btn.present?
      add_button = subscribe_btn || s('#login-to-subscribe')
      wait_until {add_button.displayed?}

      add_button.click
      if(logged_in)
        popup_okay = s('#source-added-popup #okay')
        wait_until { popup_okay.displayed? }
        popup_okay.click
      end
    end

    def unsubscribe
      unsubscribe_btn.click
      pause(0.2)
      @d.switch_to.alert.accept
    end

    def subscribe_btn
      s('#stream-panel #startCollecting')
    end

    def unsubscribe_btn
      s('#stream-panel #stopCollecting')
    end

  end
end