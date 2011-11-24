module Collectr
  class GroupsRetriever
    include Collectr::Flickr

    attr_reader :collector

    def initialize(collector)
      @collector = collector
    end

    def groups
      flickr.people.getPublicGroups(user_id: @collector.user_id)
    end

    def group_streams
      groups.map do |group_info|
        FlickrStream.find_or_create(user_id: group_info.nsid, username: group_info.name, collector: @collector, type: GroupStream.to_s)
      end
    end

  end
end