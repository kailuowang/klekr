include Collectr::RakeHelper

namespace :sync do
  desc 'sync all streams'
  task :all_streams => :environment do
    num_of_pic_synced = FlickrStream.sync_all(nil, true)
    output("All stream synced #{Time.now.to_s(:short)}")
  end

  desc "refresh personal insterestingness for unviewed picture"
  task :picture_ratings => :environment do
    Picture.reset_stream_ratings
    output("All unviewed picture's stream ratings refreshed." )
  end

  desc "sync collection for all collector that hasn't yet"
  task :collections => :environment do
    puts "start to sync collection for all collectors @#{DateTime.now}"
    Collector.where(collection_synced: false).each do |collector|
      collector.import_all_from_flickr(false)
      print "."
    end
    puts "Finished syncing collection for all collectors @#{DateTime.now}"
  end
end

