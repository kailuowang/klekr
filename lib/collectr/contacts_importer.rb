module Collectr
  class ContactsImporter
    include Collectr::Flickr

    attr_reader :collector

    def initialize(collector)
      @collector = collector
    end

    def contacts
      flickr.contacts.getList.map do |fcontact|
        {user_id: fcontact.nsid, username: fcontact.username}
      end
    end

    def import(params)
      opts = params.slice(:user_id, :username, :type).merge(collecting: true, collector: @collector)
      new_streams =
        if(opts[:type])
          [FlickrStream.find_or_create(opts)]
        else
          [ FlickrStream.find_or_create(opts.merge(type: FaveStream.name)),
            FlickrStream.find_or_create(opts.merge(type: UploadStream.name))]
        end
      new_streams.each do |stream|
        stream.sync
      end
    end
  end
end