require File.expand_path('../spec_helper', __FILE__)

describe "Editor's Choice page" do
  include Functional::DataUtil

  before :all do
    @page = Functional::EditorsChoicePage.new
  end

  after :all do
    @page.close
  end


  describe 'display photos' do
    it 'as grid' do
      @page.open
      @page.wait_until_grid_shows
    end
  end

  describe 'display single picture url' do
    def check_reload_picture
      @page.grid_pictures[2].click
      @page.wait_until_slide_shows
      src = @page.slide_picture['src']
      @page.refresh
      @page.wait_until_slide_shows
      @page.slide_picture['src'].should == src
    end

    it 'can load picture without login' do
      @page.log_out
      @page.open
      check_reload_picture
    end

    it 'can load picture when login' do
      mystream = Functional::SlideshowPage.new
      mystream.open #opens my stream page which logs in automatically
      @page.open
      check_reload_picture
      mystream.close
    end
  end

end