module Collectr
  class GarbageCollector

    def clean
      outdated_pics.delete_all
      pics_from_temporary_sources.old(1).delete_all
      uncollected_streams.old(7).delete_all
    end

    def report
      <<EOF
      Total Pictures: #{Picture.count}
      Total Faved Pictures: #{Picture.faved.count}
      Total Viewed Pictures: #{Picture.viewed.count}
      Temporary Pictures : #{pics_from_temporary_sources.count}
      Outdated Pictures : #{outdated_pics.count}
      Temporary Streams : #{uncollected_streams.count}
EOF
    end

    private
    def pics_from_temporary_sources
      Picture.where(collected: [false, nil]).unfaved
    end

    def outdated_pics
      Picture.viewed.unfaved.old(7)
    end

    def uncollected_streams
      FlickrStream.where(collecting: false)
    end

  end
end