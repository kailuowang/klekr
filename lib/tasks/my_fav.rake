namespace :my_fave do
  desc 'download my favorite photos'
  task :download => :environment do
    Collectr::FavDownloadr.new(Collectr::FLICKR_USER_ID).download
  end

  desc 'mark all my fave as faved'
  task :mark_all_as_faved => :environment do
    stream = FaveStream.find_by_user_id(Collectr::FLICKR_USER_ID)
    if(stream)
      stream.pictures.each do |pic|
        pic.update_attribute(:rating, 1)
      end
    end
  end
end
