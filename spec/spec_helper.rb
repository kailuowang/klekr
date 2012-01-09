require 'rubygems'
require 'spork'
require 'factory_girl'

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

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    config.use_transactional_fixtures = Rails.env.test?
  end
  # This code will be run each time you run your specs.
  FactoryGirl.definition_file_paths = [
    File.join(Rails.root, 'spec', 'factories')
  ]
  FactoryGirl.find_definitions
end

Spork.each_run do
  Dir[Rails.root.join("spec/support/functional/bases/*.rb")].each {|f| require f}
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end