include Collectr::RakeHelper

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
  task :sync_dates, [:days, :needs] => :environment do |_, ags|
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

  desc "collector info"
  task :collectors => :environment do
    Picture.update_all("collector_id = NULL")
    FlickrStream.update_all("collector_id = NULL")
    Collector.delete_all
  end

  desc "personal rating"
  task :collection => :environment do
    Picture.faved.update_all("faved_at = NULL, rating = 0")
  end

  desc "garbage"
  task :garbage => :environment do

    cleaner = Collectr::GarbageCollector.new
    output("========Start to clean garbage=========")
    output(cleaner.report)
    cleaner.clean
    output("After clean")
    output(cleaner.report)
    output("=======Finish cleanning garbage=========")

  end

end
