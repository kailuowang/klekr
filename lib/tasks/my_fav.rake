desc 'download my favorite photos'
namespace :my_fav do
  task :download => :environment do
    Collectr::FavDownloadr.new(Collectr::FLICKR_USER_ID).download
  end
end
