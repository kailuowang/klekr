namespace :my_fave do
  desc 'download my favorite photos'
  task :download, [:user] => :environment do |_, args|
    Collectr::FavDownloadr.new(args[:user]).download_faves
  end

end
