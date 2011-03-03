namespace :seed do
  desc "seed fave streams from google reader"
  task :fave_streams => :environment do
    seed_stream('fave')
  end

  desc "seed upload streams from google"
  task :upload_streams => :environment do
    seed_stream('upload')
  end

  def seed_stream(type)
    info = File.read("data/#{type}.xml")
    user_ids = info.scan(/=\d+@N\d\d/).map{|s|s.gsub(/=/,'')}.uniq
    user_ids.each do |user_id|
      stream = FlickrStream.build('type' => type, user_id: user_id )
      stream.save!
      p "#{type} stream created for #{stream.username}"
    end

  end
end