#
set :output, "/app/collectr/log/cron.log"

every 1.day, :at => '6:30am' do
  rake 'clean:garbage'
end

every 1.day, :at => '7:00am' do
  rake 'sync:all_streams'
end

every 1.day, :at => '7:00pm' do
  rake 'sync:all_streams'
end

every 1.day, :at => '8:30am' do
  rake 'sync:collections'
end

