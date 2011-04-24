namespace :seed do
  desc "seed fave streams from google reader"
  task :fave_streams => :environment do
    seed_stream('fave')
  end

  desc "seed upload streams from google"
  task :upload_streams => :environment do
    seed_stream('upload')
  end

  task :monthly_scores => :environment do
    FlickrStream.all.each do |stream|
      score = stream.score_for(Date.today)
      if(score.num_of_pics == 0)
        score.add_num_of_pics(stream.syncages.size)
      end
    end
  end

  task :dev_collector => :environment do
    user_id = flickr.test.login.user_id
    unless Collector.find_by_user_id(user_id)
      auth = flickr.auth
      collector = Collector.create(user_id: user_id,
                                   user_name: auth.user.username,
                                   full_name: auth.user.fullname,
                                   auth_token: auth.token)
      Picture.update_all("collector_id = #{collector.id}", :collector_id => nil)
      FlickrStream.update_all("collector_id = #{collector.id}", :collector_id => nil)
    end
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