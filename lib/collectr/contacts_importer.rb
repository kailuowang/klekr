module Collectr
  class ContactsImporter
    include Collectr::Flickr

    attr_reader :collector

    def initialize(collector)
      @collector = collector
    end

    def import
      list = flickr.contacts.getList
    end
  end
end