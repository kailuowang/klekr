require 'bundler/setup'
require 'flickr-objects'
require 'oauth'
require 'yaml'
require 'pp'
require 'ostruct'

# Load Flickr configuration
flickr_config = YAML.safe_load(File.read("#{__dir__}/config/flickr.yml"), aliases: true)['development']

# Configure the Flickr client
Flickr.configure do |config|
  config.api_key = flickr_config['api_key']
  config.shared_secret = flickr_config['shared_secret']
  
  if flickr_config['access_token'] && flickr_config['access_token_secret']
    config.access_token_key = flickr_config['access_token']
    config.access_token_secret = flickr_config['access_token_secret']
  end
end

# Print out available methods on the Flickr::People class
puts "Available methods on Flickr::People:"
pp Flickr.people.methods - Object.methods

# Test getting a specific user
puts "\nTesting user lookup by id:"
begin
  user = Flickr.people.find_by_id("45425373@N00")
  puts "User found: #{user.inspect}"
  puts "Username: #{user.username}"
  puts "Real name: #{user.real_name}"
  puts "Icon URL: #{user.icon_url}"
rescue => e
  puts "Error: #{e.message}"
end

# Test an alternative approach
puts "\nTesting alternative lookup methods:"
methods = [:find_by_username, :find_by_email, :find_by_id]
methods.each do |method|
  puts "Method: #{method}"
  if Flickr.people.respond_to?(method)
    puts "  Exists!"
  else
    puts "  Doesn't exist"
  end
end

# Create a mock user object to test the structure
puts "\nCreating a mock user:"
mock_user = OpenStruct.new(
  username: "test_user",
  real_name: "Test User",
  id: "test123@N00",
  path_alias: "test_user",
  icon_url: "https://www.flickr.com/buddyicons/test123@N00.jpg"
)
puts "Mock user: #{mock_user.inspect}"