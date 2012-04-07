namespace :admin do
  namespace :report do
    desc 'report collectors'
    task :collectors => :environment do
      Collector.report.each do |c|
        puts "#{c.user_name}(#{c.full_name}) [ #{c.user_id} ]: "
        puts "Registered at: " + c.created_at.to_s
        puts "Last Login at: #{c.last_login}"
        puts "Total Sources: " + c.flickr_streams.collecting.count.to_s
        puts "Total Pictures: " + c.pictures.count.to_s
        puts "Total Pictures Viewed: " + c.pictures.viewed.count.to_s
        puts "Total Pictures Faved: " + c.pictures.faved.count.to_s
        puts "========================================="
      end
    end

    desc 'report statistics'
    task :statistics => :environment do
      puts "#{Picture.count} pictures."
      puts "#{Collector.count} collectors in total."
      puts "#{Collector.where(['last_login > ?', 10.days.ago]).count} collectors active in last 10 days."
      active_collectors = Collector.all.select do |collector|
        collector.flickr_streams.count > 0
      end
      puts "#{active_collectors.size} collectors that has more than one source."
      puts "#{FlickrStream.collecting.count} syncing flickr streams."
    end
  end



end

