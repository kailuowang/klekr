namespace :functional do

  def import_contacts(collector)
    Collectr::ContactsImporter.new(collector).contact_streams.each do |stream|
      stream.subscribe
      stream.sync(nil, 20)
    end
  end

  desc "prepare for functional suites"
  task :prepare => :environment do
    testUser = ::Collector.find_or_create(user_id: Collectr::TestFlickrUserId,
                               user_name: Collectr::TestFlickrUserName,
                               auth_token: Collectr::TestFlickrAuthToken)
    import_contacts testUser
    devUser = ::Collector.find_or_create(user_id: Collectr::DevFlickrUserId,
                               user_name: Collectr::DevFlickrUserName,
                               auth_token: Collectr::DevFlickrAuthToken)
    import_contacts devUser
    editor = Collectr::Editor.new.ensure_editor_collector
    editor.import_from_flickr(300)
  end

  desc "run functional suites"
  task :run do
    ENV['RAILS_ENV'] = 'development'
    sh 'rspec ./functional'
    puts "functional suites passed!"
  end
end

