require File.expand_path('../../spec/spec_helper', __FILE__)

Rails.logger = Logger.new('log/functional.log')
ActiveRecord::Base.logger = Rails.logger


RSpec.configure do |config|
  def assert_no_js_error page
    if page
      page.js_error.should == nil
    end
  end

  def capture_screen_when_fails example, page
    if(example.exception.present? and page.present?)
      page.capture_screen(capture_name(example))
    end
  end

  def capture_name(example)
    example.description.gsub(/'/, "").gsub(/\s/, '_')
  end

  config.after(:each) do
    assert_no_js_error @page
    capture_screen_when_fails(example, @page)
  end
end