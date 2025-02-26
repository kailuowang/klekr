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

# Test the Flickr API
puts "Testing Flickr API contacts methods..."

# List all available people methods
puts "\nAvailable methods on Flickr::People:"
pp Flickr.people.methods - Object.methods

puts "\nAvailable methods on Flickr::Person instance:"
person = Flickr.people.find("me")
pp person.methods - Object.methods

# Try to find the contacts method
puts "\nSearching for contacts-related methods in Flickr API:"
all_methods = Flickr.methods - Object.methods
contacts_methods = all_methods.select { |m| m.to_s.include?("contact") }
puts "Methods that include 'contact': #{contacts_methods.join(', ')}"

# Check available methods in the Flickr::Contacts namespace
if Flickr.respond_to?(:contacts)
  puts "\nAvailable methods on Flickr::Contacts:"
  pp Flickr.contacts.methods - Object.methods
  
  # Try to get the contacts list
  puts "\nTrying to get contacts list:"
  begin
    contacts = Flickr.contacts.get_list
    puts "Found #{contacts.size} contacts!"
    contacts.first(3).each do |contact|
      puts "Contact: #{contact.inspect}"
      puts "  Available methods: #{(contact.methods - Object.methods).first(10).join(', ')}..."
    end
  rescue => e
    puts "Error: #{e.message}"
  end
else
  puts "Flickr doesn't have a contacts module."
end