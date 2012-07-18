namespace :one_time do
  desc 'update the faved_at date'
  task :update_faved_at => :environment do
    Picture.update_all('faved_at = updated_at', 'faved_at IS NULL AND rating > 0')
  end

  desc 'update description'
  task :update_desc => :environment do
    Collector.report.each do |c|
      c.pictures.each do |pic|
        begin
          pi = flickr.photos.getInfo(photo_id: pic.pic_info.id)
          pic.update_attribute(:description, pi.description) if pi.description.present?
          print '.'
        rescue
          pic.update_attributes(no_longer_valid: true)
        end
      end
    end
  end

  desc 'exchange_token'
  task :exchange_tokens => :environment do
    count = 0
    Collector.report.each do |c|
      begin
        c.exchange_token
        count += 1
      rescue => e
        Rails.logger.error e.inspect
      end
    end
    output "successfully exchanged tokens for #{count} / #{Collector.count} collectors"
  end
end