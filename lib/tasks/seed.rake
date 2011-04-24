namespace :seed do

  desc "create the collector for development purpose, which will be used as the current collector when authentication is turned off"
  task :dev_collector => :environment do
    user_id = flickr.test.login.id
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

end