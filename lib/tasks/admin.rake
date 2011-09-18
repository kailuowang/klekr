namespace :admin do
  namespace :report do
    desc 'report collectors'
    task :collectors => :environment do
      Collector.all.each do |c|
        puts "#{c.user_name}(#{c.full_name}): "
        puts "Registered at: " + c.created_at.to_s
        puts "Total Sources: " + c.flickr_streams.collecting.count.to_s
        puts "Total Pictures: " + c.pictures.count.to_s
        puts "Total Pictures Viewed: " + c.pictures.viewed.count.to_s
        puts "Total Pictures Faved: " + c.pictures.faved.count.to_s
        puts "========================================="
      end
    end
  end

end

