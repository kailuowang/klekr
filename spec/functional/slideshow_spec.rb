require 'spec_helper'
#require 'selenium-webdriver'

describe "slideshow" do

  before :all do
    @d = Selenium::WebDriver.for :firefox
    @d.manage.window.size = Selenium::WebDriver::Dimension.new(1024, 768)
    @d.manage.timeouts.implicit_wait = 2 # seconds
  end

  before :each do
    @d.get "http://localhost:3000/slideshow"
    @w = Selenium::WebDriver::Wait.new(:timeout => 2) # seconds

  end

  after :all do
    @d.quit
  end

  it "displays the picture by default" do
    element = @d["picture"]
    @w.until { element.displayed? }
    element.should be_displayed
  end


  it "display the next page when the next button was clicked" do
    element = @d["picture"]
    current_src = element['src']
    @d['right'].click
    element['src'].should_not == current_src
  end

  it "switch off when clicked" do
    element = @d["picture"]
    element.click
    element.should_not be_displayed
  end
end
