require File.expand_path('../spec_helper', __FILE__)

describe "Editor's Choice page" do
  include Functional::DataUtil

  before :all do
    @page = Functional::SlideshowPage.new
  end

  after :all do
    @page.close
  end

  def open
    @page.open 'editors_choice', true
  end

  describe 'display photos' do
    it 'as grid' do
      open
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
      open
      check_reload_picture
    end

    it 'can load picture when login' do
      @page.open #opens my stream page which logs in automatically
      open
      check_reload_picture
    end
  end

end