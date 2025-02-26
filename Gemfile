source 'https://rubygems.org'

gem 'rails', '~> 7.1.0'
gem 'propshaft'
gem 'puma'

# Standard Rails components
gem 'haml'
gem 'flickraw'

gem 'jquery-rails'
gem 'capistrano'
gem 'will_paginate'
gem 'config' # replaces rails_config
gem 'delayed_job_active_record'
gem 'whenever', require: false
gem 'json'

# Assets
gem 'sprockets-rails'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jsbundling-rails'
gem 'cssbundling-rails'
gem 'uglifier'

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'selenium-webdriver'
  gem 'coffee-rails' # For CoffeeScript support
end

group :development do
  gem 'web-console'
  gem 'error_highlight', '>= 0.4.0', platforms: [:ruby]
end

group :test do
  gem 'capybara'
end

group :production do
  # Temporarily commented out to allow local testing
  # gem 'mysql2'
  gem 'execjs'
  gem 'mini_racer'
  gem 'newrelic_rpm'
end

# For compatibility with test framework
gem "rexml"
gem "spork", "~> 0.9.2"

gem "bootsnap", "~> 1.18"
