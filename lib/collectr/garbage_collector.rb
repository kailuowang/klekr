module Collectr
  class GarbageCollector

    def clean
      outdated_pics.delete_all
      uncollected_streams.old(7).delete_all
      invalid_pics.delete_all
      really_old_pics.delete_all
    end

    def report
      <<EOF
      Total Pictures: #{Picture.count}
      Total Faved Pictures: #{Picture.faved.count}
      Total Viewed Pictures: #{Picture.viewed.count}
      Outdated Pictures : #{outdated_pics.count}
      Invalide Pictures: #{invalid_pics.count}
      Really Old Pictures: #{really_old_pics.count}
      Temporary Streams : #{uncollected_streams.count}
EOF
    end

    private

    def outdated_pics
      Picture.viewed.unfaved.old(14)
    end

    def invalid_pics
      Picture.where(no_longer_valid: true)
    end

    def uncollected_streams
      FlickrStream.where(collecting: false)
    end

    def really_old_pics
      Picture.where('date_upload < ?', 12.months.ago).unfaved
    end

  end
end