module Collectr

  module FlickrSyncor
    def sync_using photos_method
      class_eval <<-RUBY
        def sync_pictures_from_flickr
          #{photos_method}( user_id: user_id, extras: 'date_upload').each do |pic_info|
            Picture.create_from_pic_info(pic_info)
          end
        end
      RUBY
    end
  end
end