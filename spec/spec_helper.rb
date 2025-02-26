require 'rubygems'
require 'factory_bot'
require 'spork'

module SpecHelper
  def self.load_env
    require File.expand_path("../../config/environment", __FILE__)
    require 'rspec/rails'
  end
end

Spork.prefork do
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  SpecHelper.load_env
  
  RSpec.configure do |config|
    config.mock_with :rspec
    
    # Factory Bot configuration
    config.include FactoryBot::Syntax::Methods
    
    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]
    
    # Use transactions for speed
    config.use_transactional_fixtures = true
    
    # Filter which specs to run
    config.filter_run_when_matching :focus
    config.run_all_when_everything_filtered = true
    
    # Randomize test order for better isolation
    config.order = :random
    Kernel.srand config.seed
    
    # Allow some monkey patching for describe_private.rb to work
    # config.disable_monkey_patching!
    
    # Use the documentation formatter for detailed output
    config.default_formatter = 'doc' if config.files_to_run.one?
  end
  
  # Factory definitions will be loaded by FactoryBot Rails automatically
  
  # For backward compatibility
  unless defined?(FactoryGirl)
    FactoryGirl = FactoryBot
  end
end

Spork.each_run do
  # Load all support files
  Dir[Rails.root.join("spec/support/functional/bases/*.rb")].each {|f| require f}
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end