
namespace :clean do
  desc "clean synced pictures"
  task :pictures => :environment do
    Syncage.delete_all
    Picture.delete_all
  end

  desc "clean all flickr stream"
  task :flickr_streams => :environment do
    FlickrStream.destroy_all
  end

  desc "clean flickr stream's last sync date"
  task :sync_dates, :days, :needs => :environment do |_, ags|
    FlickrStream.all.each do |stream|
      stream.update_attribute(:last_sync, ags[:days].to_i.days.ago)
    end
  end

  desc "clean all ratings"
  task :ratings => :environment do
    MonthlyScore.delete_all
  end

  desc "re-calculate personal interestingness for all unviewed pictures"
  task :picture_ratings => :environment do
    Picture.reset_stream_ratings
  end

end
