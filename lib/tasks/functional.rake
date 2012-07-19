namespace :functional do

  def import_contacts(collector)
    Collectr::ContactsImporter.new(collector).contact_streams.each do |stream|
      stream.subscribe
      stream.sync(nil, 20)
    end
  end

  desc "prepare for functional suites"
  task :prepare => :environment do
    include Collectr::TestDataUtil

    import_contacts test_collector
    import_contacts dev_collector

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

