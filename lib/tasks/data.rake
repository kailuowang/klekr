namespace :data do
  desc 'check integrity'
  task :check_integrity => :environment do
    FlickrStream.all.each do |stream|
      puts "#{stream.type} for #{stream.username} is missing collector" if stream.collector.nil?
    end
  end
end
