require 'spec_helper'

describe "slideshow" do

  before :all do
    Picture.order('updated_at DESC').limit(50).update_all(viewed: false)
    @page = Functional::SlideshowPage.new
  end

  before :each do
    @page.open
  end

  after :all do
    @page.close
  end

  it "displays the picture by default" do
    @page.wait_until { @page.slide_picture.displayed? }
  end

  it "display the next page when the next button was clicked" do
    current_src = @page.slide_picture['src']
    @page.click_right_button
    @page.slide_picture['src'].should_not == current_src
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
    pic_id = @page.slide_picture['data-pic-id']
    @page.slide_picture.click
    @page.highlighted_grid_picture['id'].should == "pic-#{pic_id}"
  end

  it "display 6 grid picture according to the screen size" do
    @page.slide_picture.click
    @page.grid_pictures.size.should == 6
  end

  it "switches to the next page of grid when navigate through slide" do
    @page.slide_picture.click
    pic_ids = @page.grid_pictures_ids
    @page.last_grid_picture.click
    @page.pause 1
    @page.click_right_button

    @page.slide_picture.click
    @page.pause 1
    pic_ids.should_not == @page.grid_pictures_ids

  end


end
