# Flickr API Migration Plan for Klekr

## Background
Klekr was using the `flickraw` gem which has become outdated and incompatible with Flickr's current API requirements. This document outlines the migration plan to update Klekr to use the more current `flickr-objects` gem.

## Step 1: Update Dependencies

1. Update the Gemfile to replace flickraw with flickr-objects:
   ```ruby
   # gem 'flickraw'
   gem 'flickr-objects', '~> 0.6.3'
   ```

2. Run `bundle install` to install the new gem.

## Step 2: Configure Authentication

1. Update the flickr.yml structure to match the OAuth authentication required by flickr-objects:
   ```yaml
   defaults: &defaults
     api_key: YOUR_API_KEY
     shared_secret: YOUR_SHARED_SECRET
     access_token: # Will be filled during authentication
     access_token_secret: # Will be filled during authentication

   development:
     <<: *defaults

   test:
     <<: *defaults

   production:
     <<: *defaults
   ```

2. Create a manual authentication helper script at `bin/manual_flickr_auth` to help users get their OAuth tokens.

## Step 3: Update Initializers

Update the initializer at `config/initializers/flickraw.rb` to use flickr-objects:

```ruby
module Collectr
  # Load Flickr configuration
  FlickrConfig = YAML.safe_load(File.read("#{Rails.root}/config/flickr.yml"), aliases: true)[Rails.env]

  # Initialize the Flickr client
  require 'flickr-objects'
  
  Flickr.configure do |config|
    config.api_key = FlickrConfig['api_key']
    config.shared_secret = FlickrConfig['shared_secret']
    
    if FlickrConfig['access_token'] && FlickrConfig['access_token_secret']
      config.access_token_key = FlickrConfig['access_token']
      config.access_token_secret = FlickrConfig['access_token_secret']
    end
  end
  
  FLICKR_CLIENT = Flickr
end
```

## Step 4: Update Model and Controller Code

Throughout the codebase, you'll need to update any code that uses the FlickRaw API to use the flickr-objects gem's API instead.

### Common Method Changes:

1. **Searching for photos**

   FlickRaw:
   ```ruby
   flickr.photos.search(user_id: user_id, per_page: 100)
   ```

   flickr-objects:
   ```ruby
   Flickr.photos.search(user_id: user_id, per_page: 100)
   ```

2. **Getting photo information**

   FlickRaw:
   ```ruby
   photo_info = flickr.photos.getInfo(photo_id: photo_id)
   ```

   flickr-objects:
   ```ruby
   photo_info = Flickr.photos.find_by_id(photo_id)
   ```

3. **Getting a user's favorites**

   FlickRaw:
   ```ruby
   flickr.favorites.getList(user_id: user_id, per_page: 100)
   ```

   flickr-objects:
   ```ruby
   Flickr.people.find_by_username(username).favorites(per_page: 100)
   ```

## Step 5: Testing

After implementing all changes, thoroughly test the application to ensure all Flickr-related functionality works correctly.

## References

- flickr-objects documentation: https://github.com/janko/flickr-objects
- Flickr API documentation: https://www.flickr.com/services/api/