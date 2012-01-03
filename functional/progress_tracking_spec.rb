require File.expand_path('../../spec/spec_helper', __FILE__)

describe "progress tracking in my stream page" do
  include Functional::DataUtil

  before :all do
    reset_viewed_pictures
    @page = Functional::SlideshowPage.new
  end

  before :each do
    @page.open
  end

  after :all do
    @page.close
  end

  describe 'tracking in slide mode' do
    it "mark the picture as viewed after going to the next" do
      pic_src = @page.slide_picture['src']
      @page.click_right_button
      @page.open
      @page.slide_picture['src'].should_not == pic_src
    end

    it "mark the picture as viewed after enter the grid mode from that picture" do
      pic_src = @page.slide_picture['src']
      @page.slide_picture.click
      @page.pause
      @page.open
      @page.slide_picture['src'].should_not == pic_src
    end
  end

  describe 'tracking in grid mode' do
    it "mark the all pictures in the current page as viewed when navigate to the next page" do
      @page.enter_grid_mode
      pic_ids_in_page = @page.grid_pictures_ids
      @page.click_right_button
      @page.wait_until_grid_shows
      @page.open
      pic_ids_in_page.should_not include(@page.slide_picture_id)
    end

  end

end