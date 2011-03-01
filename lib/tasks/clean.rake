
namespace :clean do
  desc "clean synced pictures"
  task :pictures => :environment do
    Syncage.destroy_all
    Picture.destroy_all
  end
end
