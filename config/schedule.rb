#
set :output, "/app/collectr/log/cron.log"

every 1.day, :at => '5:30am' do
  rake 'clean:garbage'
  rake 'sync:all_streams'
  rake 'sync:picture_ratings'
end

