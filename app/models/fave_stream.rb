
require 'flickraw'
class FaveStream < FlickrStream
  sync_using 'flickr.favorites.getList'
end
