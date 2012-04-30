include Collectr::RakeHelper

namespace :sync do
  desc 'sync all streams'
  task :all_streams => :environment do
    with_error_report do
      results = FlickrStream.sync_all(verbose: true, synced_before: 20.hours.ago)
      output("All stream synced #{Time.now.to_s(:short)}")
      AdminMailer.regular_report("klekr streams were successfully synced", "#{results[:total_pictures_synced]} pictures from #{results[:total_streams_synced]} were synced out of #{results[:total_streams_to_sync]} streams scheduled to sync" )
    end
  end

  desc "refresh personal insterestingness for unviewed picture"
  task :picture_ratings => :environment do
    Picture.reset_stream_ratings
    output("All unviewed picture's stream ratings refreshed." )
  end

  desc "sync collection for all collector that hasn't yet"
  task :collections => :environment do
    with_error_report do
      puts "start to sync collection for all collectors @#{DateTime.now}"
      count = Collector.where(collection_synced: false).each do |collector|
        collector.import_all_from_flickr(false)
        print "."
      end.count
      puts "Finished syncing collection for all collectors @#{DateTime.now}"
      AdminMailer.regular_report("Fave synced successfully", "#{count} collectors' fave were synced",  )
    end
  end
end

