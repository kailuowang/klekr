require File.expand_path('../spec_helper', __FILE__)

describe "Stream slide page" do
  include Functional::DataUtil

  before :all do
    @page = Functional::SlideshowPage.new
  end


  after :all do
    @page.close
  end

  describe 'browsing' do
    it 'displays pictures from flickr'
  end

end