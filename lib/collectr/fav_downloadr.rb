require 'flickraw'
#DEPRECATED
module Collectr
  class FavDownloadr

    def initialize(user_id)
      @user_id = user_id
      @count = 0
      @logger = Rails.logger
    end

    def download_faves
      (0..70).each do |page|
        faves = flickr.favorites.getList(user_id: @user_id, per_page: 100, page: page, extras: 'url_o')
        @logger.info("downloading page ##{page}")
        faves.each do |fave|
          download_pic fave
        end
      end

    end

    def save_pic(resp, url)
      open("tmp/#{File.basename(url.path)}", "wb") { |file|
        file.write(resp.body)
      }
    end

    def download_pic(pic)
      url = URI.parse( pic.respond_to?(:url_o) ? pic.url_o : FlickRaw.url_z(pic))
      Net::HTTP.start(url.host) do |http|
        resp = http.get(url.path)
        if (resp.code == '200')
          @logger.info("downloading picture #{@count += 1} #{pic.title} @ #{url}")
          save_pic(resp, url)
        else
          @logger.info('picture missing from flickr, skipped')
        end
      end
    end

  end
end

