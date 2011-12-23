module Collectr
  class ContactsImporter
    include Collectr::Flickr

    attr_reader :collector

    def initialize(collector)
      @collector = collector
    end

    def contact_streams
      response = flickr.contacts.getList
      if response['total'] > 0
        response.map do |fcontact|
          opts = {user_id: fcontact.nsid, username: fcontact.username, collector: @collector}
          [ FlickrStream.find_or_create(opts.merge(type: FaveStream.name)),
            FlickrStream.find_or_create(opts.merge(type: UploadStream.name))]
        end.flatten
      else
        []
      end
    end
  end
end