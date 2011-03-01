namespace :my_fav do
  desc 'download my favorite photos'
  task :download => :environment do
    Collectr::FavDownloadr.new(Collectr::FLICKR_USER_ID).download
  end
end
