include Collectr::RakeHelper

namespace :sync do
  desc 'sync all streams'
  task :all_streams => :environment do
    num_of_pic_synced = FlickrStream.sync_all
    output("All stream synced. #{num_of_pic_synced} pictures were collected" )
  end

  desc "refresh personal insterestingness for unviewed picture"
  task :picture_ratings => :environment do
    Picture.reset_stream_ratings
    output("All unviewed picture's stream ratings refreshed." )
  end
end

