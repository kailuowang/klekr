module Collectr
  module FlickrIcon
    def icon_url
      # Try to use the user object's icon_url if it's available
      if respond_to?(:user) && user.respond_to?(:icon_url) && user.icon_url.present?
        user.icon_url
      else
        # Fall back to the default buddy icon pattern
        "https://www.flickr.com/buddyicons/#{user_id}.jpg"
      end
    end
  end
end