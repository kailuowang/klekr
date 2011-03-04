
namespace :clean do
  desc "clean synced pictures"
  task :pictures => :environment do
    Syncage.destroy_all
    Picture.destroy_all
  end

  desc "clean all flickr stream"
  task :flickr_streams => :environment do
    FlickrStream.destroy_all
  end

  desc "clean flickr stream's last sync date"
  task :sync_dates => :environment do
    FlickrStream.all.each do |stream|
      stream.update_attribute(:last_sync, 1.month.ago)
    end
  end
end
