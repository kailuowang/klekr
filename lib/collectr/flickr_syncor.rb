module Collectr

  module FlickrSyncor
    def sync_using photos_method
      class_eval <<-RUBY
        def sync_pictures_from_flickr(flickr_stream = nil)
          #{photos_method}( user_id: user_id, extras: 'date_upload').each do |pic_info|
            picture = Picture.create_from_pic_info(pic_info)
            Syncage.find_or_create(picture_id: picture.id, flickr_stream_id: flickr_stream.id) if(flickr_stream)

          end
        end
      RUBY
    end
  end
end