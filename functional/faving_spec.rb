require File.expand_path('../../spec/spec_helper', __FILE__)

describe "fave pictures" do
  include Functional::DataUtil

  before :all do
    reset_faved_pictures
    @page = Functional::SlideshowPage.new
  end

  after :all do
    @page.close
  end

  def open_fave_page
    @page.open 'slideshow/faves', true
  end

  describe 'fave picture in my stream' do

    before :each do
      @page.open
    end

    it "faved picture should show up in my fave page" do
      pic_id = @page.slide_picture_id

      @page.fave_button.click
      @page.fave_rating_star(1).click
      @page.pause
      @page.open 'slideshow/faves', true
      @page.highlighted_grid_picture_id.should == pic_id
    end

    it "hide the fave button after the picture is faved" do
      @page.click_right_button
      @page.fave_button.click
      @page.fave_rating_star(1).click
      @page.pause
      @page.fave_button.should_not be_displayed
      @page.unfave_button.should be_displayed
    end

    it "unfave picture should disapear from my fave page" do
      @page.click_right_button
      @page.click_right_button

      pic_id = @page.slide_picture_id

      @page.fave_button.click
      @page.fave_rating_star(1).click
      @page.pause
      @page.unfave_button.click
      @page.pause
      open_fave_page
      @page.highlighted_grid_picture_id.should_not == pic_id
    end
  end

  describe "browsing faves" do
    before :all do
      clear_faved_pictures
    end

    it 'automatically load faves from flickr when browsing' do
      open_fave_page

      @page.click_right_button
      @page.grid_pictures.size.should == 6
    end
  end
end