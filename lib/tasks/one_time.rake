namespace :one_time do
  desc 'update the faved_at date'
  task :update_faved_at => :environment do
    Picture.update_all('faved_at = updated_at', 'faved_at IS NULL AND rating > 0')
  end
end