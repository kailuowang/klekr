require File.expand_path('../../spec/spec_helper', __FILE__)

Rails.logger = Logger.new('log/functional.log')
ActiveRecord::Base.logger = Rails.logger

RSpec.configure do |config|
  config.after(:each) do
     if @page
       @page.js_error.should == nil
     end
  end
end