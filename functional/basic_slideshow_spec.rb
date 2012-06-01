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

    before :each do
      @page.wait_until_slide_shows
    end

    it "displays the picture by default" do
      @page.slide_picture.should be_displayed
    end

    it "display the next picture when the right arrow button was clicked" do
      current_src = @page.slide_picture['src']
      @page.click_right_button
      @page.wait_until do
        @page.slide_picture['src'] != current_src
      end
    end

    it "display the previous picture when click the left arrow button" do
      current_src = @page.slide_picture['src']
      @page.click_right_button
      @page.click_left_button
      @page.wait_until do
        @page.slide_picture['src'] == current_src
      end
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
      @page.grid_pictures.size.should > 3
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

    it "hide slide picture and display grid when clicked" do
      @page.click_slide_picture
      @page.slide_picture.should_not be_displayed
      @page.grid_pictures.each do |grid_picture|
        grid_picture.should be_displayed
      end
    end

    it "highlight the corresponding grid picture when switch to grid" do
      @page.click_right_button
      @page.click_right_button
      @page.pause
      @page.wait_until_slide_shows
      pic_id = @page.slide_picture_id
      @page.click_slide_picture
      @page.wait_until do
        @page.highlighted_grid_picture_id == pic_id
      end
    end

    it "switches to the next page of grid when navigate through slide" do
      @page.click_slide_picture
      pic_ids = @page.grid_pictures_ids
      @page.last_grid_picture.click
      @page.wait_until_slide_shows
      @page.click_right_button
      @page.wait_until_slide_shows
      @page.click_slide_picture
      @page.wait_until_grid_shows
      @page.wait_until do
        @page.grid_pictures_ids != pic_ids
      end

    end
  end

  describe "navigation buttons" do
    before :all do
      reset_viewed_pictures
    end

    before :each do
      @page.open
    end

    def right_button
      @page.direction_button(:right)
    end

    def left_button
      @page.direction_button(:left)
    end

    context "slide mode" do
      it 'display only the right button at the beginning' do
        right_button.should be_displayed
        left_button.should_not be_displayed
      end

      it 'display both right and left button at the second picture' do
        @page.click_right_button
        right_button.should be_displayed
        left_button.should be_displayed
      end

      it 'display only right button when navigate back to the first picture' do
        @page.click_right_button
        @page.click_left_button
        @page.wait_until do
          right_button.displayed? && !left_button.displayed?
        end
      end
    end
  end
end
