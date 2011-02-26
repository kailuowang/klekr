require 'flickraw'

module Collectr
  class FavDownloadr

    def initialize(user_id)
      @user_id = user_id
    end


    def download
      faves = flickr.favorites.getList(:user_id => @user_id)
      faves.each do |fave|
        download_pic fave
      end
    end

    def save_pic(resp, url)
      open("tmp/#{File.basename(url.path)}", "wb") { |file|
        file.write(resp.body)
      }
    end

    def download_pic(pic)
      url = URI.parse(FlickRaw.url_b(pic))
      Net::HTTP.start(url.host) do |http|
        resp = http.get(url.path)
        if (resp.code == '200')
          Rails.logger.info("downloading picture #{pic.title} @ #{url}")
          save_pic(resp, url)
        end
      end
    end

  end
end

