module Collectr
  class ContactsImporter
    include Collectr::Flickr

    attr_reader :collector

    def initialize(collector)
      @collector = collector
    end

    def contact_streams
      begin
        # Use OAuth directly to get contacts since flickr-objects doesn't expose the contacts API
        # Check for both old and new token fields
        oauth_token = @collector.oauth_token || @collector.access_token
        oauth_token_secret = @collector.oauth_token_secret || @collector.access_secret
        
        if @collector && oauth_token && oauth_token_secret
          # Create an OAuth access token
          access_token = OAuth::AccessToken.new(
            Collectr::FLICKR_OAUTH_CONSUMER,
            oauth_token,
            oauth_token_secret
          )
          
          # Make a direct request to the Flickr API to get contacts
          response = access_token.get('/services/rest/?method=flickr.contacts.getList&format=json&nojsoncallback=1')
          data = JSON.parse(response.body)
          
          if data['stat'] == 'ok' && data['contacts'] && data['contacts']['contact']
            # Process the contacts
            contacts = data['contacts']['contact']
            
            # Return flat array of streams for each contact
            contacts.map do |contact|
              opts = {
                user_id: contact['nsid'], 
                username: contact['username'] || "user_#{contact['nsid']}", 
                collector: @collector
              }
              [ 
                FlickrStream.find_or_create(opts.merge(type: FaveStream.name)),
                FlickrStream.find_or_create(opts.merge(type: UploadStream.name))
              ]
            end.flatten
          else
            # No contacts found or API error
            Rails.logger.warn("No contacts found or API error: #{data['message'] if data['stat'] != 'ok'}")
            []
          end
        else
          # No authentication credentials
          Rails.logger.warn("Cannot get contacts: missing OAuth credentials")
          []
        end
      rescue => e
        Rails.logger.error("Error fetching contacts: #{e.message}\n#{e.backtrace.join("\n")}")
        # Return empty array if we can't get contacts
        []
      end
    end
  end
end