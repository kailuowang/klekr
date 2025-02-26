desc "Get authentication token for Flickr API using flickr.rb gem"
task :authenticate => :environment do
  require_relative '../flickr_auth'
end