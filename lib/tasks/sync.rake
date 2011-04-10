namespace :sync do
  desc 'sync all streams'
  task :all_streams => :environment do
    num_of_pic_synced = FlickrStream.sync_all
    Rails.logger.info("All stream synced. #{num_of_pic_synced} pictures were collected" )
  end
end

