require File.expand_path('../spec_helper', __FILE__)

describe "Editor's Choice page" do
  include Functional::DataUtil

  before :all do
    @page = Functional::SlideshowPage.new
  end

  before :each do
    @page.open 'editors_choice', true
  end

  after :all do
    @page.close
  end

  describe 'display photos' do
    it 'as grid' do
      @page.wait_until_grid_shows
    end
  end

end