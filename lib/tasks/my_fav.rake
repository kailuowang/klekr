namespace :my_fave do
  desc 'download my favorite photos'
  task :download, [:user] => :environment do |_, args|
    Collectr::FavDownloadr.new(args[:user]).download
  end

  desc 'mark all my fave as faved'
  task :mark_all_as_faved, [:user_id] => :environment do |_, args|
    stream = FaveStream.find_by_user_id(args[:user_id])
    if(stream)
      stream.pictures.each do |pic|
        pic.update_attribute(:rating, 1)
      end
    end
  end
end
