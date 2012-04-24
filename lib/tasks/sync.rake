include Collectr::RakeHelper

namespace :sync do
  desc 'sync all streams'
  task :all_streams => :environment do
    num_of_pic_synced = FlickrStream.sync_all(verbose: true, synced_before: 3.hours.ago)
    output("All stream synced #{Time.now.to_s(:short)}")
    AdminMailer.regular_report("klekr streams were successfully synced", "#{num_of_pic_synced} pictures were synced" )
  end

  desc "refresh personal insterestingness for unviewed picture"
  task :picture_ratings => :environment do
    Picture.reset_stream_ratings
    output("All unviewed picture's stream ratings refreshed." )
  end

  desc "sync collection for all collector that hasn't yet"
  task :collections => :environment do
    puts "start to sync collection for all collectors @#{DateTime.now}"
    count = Collector.where(collection_synced: false).each do |collector|
      collector.import_all_from_flickr(false)
      print "."
    end.count
    puts "Finished syncing collection for all collectors @#{DateTime.now}"
    AdminMailer.regular_report("Fave synced successfully", "#{count} collectors' fave were synced",  )
  end
end

