require File.expand_path('../spec_helper', __FILE__)

describe "slideshow" do
  include Functional::DataUtil

  before :all do
    @page = Functional::SlideshowPage.new
  end

  before :each do
    @page.open
  end

  after :all do
    @page.close
  end

  describe 'slide mode' do
    before :all do
      reset_viewed_pictures
    end

    it "displays the picture by default" do
      @page.slide_picture.should be_displayed
    end

    it "display the next picture when the right arrow button was clicked" do
      current_src = @page.slide_picture['src']
      @page.click_right_button
      @page.slide_picture['src'].should_not == current_src
    end

    it "display the previous picture when click the left arrow button" do
      current_src = @page.slide_picture['src']
      @page.click_right_button
      @page.click_left_button
      @page.slide_picture['src'].should == current_src
    end

    it "shouldn't display the left arrow at the begining" do
      @page.left_arrow.should_not be_displayed
    end
  end

  describe 'grid mode' do
    before do
      @page.wait_until_slide_shows
      @page.slide_picture.click
    end

    before :all do
      reset_viewed_pictures
    end

    it "display 6 grid picture according to the screen size" do
      @page.grid_pictures.size.should == 6
    end

    it 'goes to the next page when right button clicked' do
      last_page_ids = @page.grid_pictures_ids
      @page.grid_next_page
      last_page_ids.each do |last_page_id|
        @page.grid_pictures_ids.should_not include(last_page_id)
      end
    end

    it 'goes back to the previous page when left button clicked' do
      last_page_ids = @page.grid_pictures_ids
      @page.click_right_button
      @page.click_left_button
      @page.grid_pictures_ids.should == last_page_ids
    end
  end

  describe 'switching between two modes' do
    before :all do
      reset_viewed_pictures
    end

    it "hide slide picture when clicked" do
      @page.slide_picture.click
      @page.slide_picture.should_not be_displayed
    end

    it "displays the grid when clicked the slide picture" do
      @page.slide_picture.click
      @page.grid_pictures.each do |grid_picture|
        grid_picture.should be_displayed
      end
    end

    it "highlight the corresponding grid picture when switch to grid" do
      @page.click_right_button
      @page.click_right_button
      pic_id = @page.slide_picture_id
      @page.wait_until_slide_shows
      @page.slide_picture.click
      @page.highlighted_grid_picture_id.should == pic_id
    end

    it "switches to the next page of grid when navigate through slide" do
      @page.slide_picture.click
      pic_ids = @page.grid_pictures_ids
      @page.last_grid_picture.click
      @page.wait_until_slide_shows
      @page.click_right_button
      @page.wait_until_slide_shows
      @page.slide_picture.click
      @page.wait_until_grid_shows
      pic_ids.should_not == @page.grid_pictures_ids

    end
  end

end
