require File.expand_path('../spec_helper', __FILE__)

describe "faving pictures" do
  include Functional::DataUtil

  before :all do
    @page = Functional::SlideshowPage.new
  end

  after :all do
    @page.close
  end

  def open_fave_page
    @page.open 'slideshow/faves', true
  end

  def just_faved? slide_pic_src
    @page.pause
    open_fave_page
    @page.enter_slide_mode
    @page.slide_picture['src'] == slide_pic_src
  end


  describe 'in my stream' do
    before :all do
      reset_faved_pictures
    end

    before :each do
      @page.open
    end

    it "faved picture should show up in my fave page" do
      pic_src = @page.slide_picture['src']

      @page.fave
      just_faved?(pic_src).should be_true
    end

    it "hide the fave button after the picture is faved" do
      @page.click_right_button
      @page.fave
      @page.fave_button.should_not be_displayed
      @page.unfave_button.should be_displayed
    end

    it "unfave picture should disapear from my fave page" do
      @page.click_right_button
      @page.click_right_button

      pic_src = @page.slide_picture['src']

      @page.fave
      @page.unfave_button.click
      @page.pause
      just_faved?(pic_src).should be_false

    end

    it 'displays the faved date on the tooltip of unfave button immediately' do
      @page.click_right_button
      @page.click_right_button

      @page.fave
      @page.unfave_button['data-content'].should include(Date.today.to_s(:long).gsub(/\s\s/, ' '))
    end
  end

  describe 'browsing with filter' do
    before :all do
      create_some_faved_pictures
      @page.pause
    end

    it "can filter by rating" do
      open_fave_page
      @page.enter_slide_mode
      pic_src = @page.slide_picture['src']
      @page.set_fave_rating(2)

      @page.set_option rating: 3

      @page.enter_slide_mode
      @page.slide_picture['src'].should_not == pic_src

      @page.set_option rating: 2

      @page.enter_slide_mode
      @page.slide_picture['src'].should == pic_src

    end

    it "can filter by date"  do
      reset_sync_status true
      clear_faved_pictures(['faved_at > ? and faved_at < ?', Date.new(2004, 1, 1), Date.new(2004, 1, 10)])
      add_faved_pictures({faved_at: Date.new(2004,1,4)}, 3)
      open_fave_page
      @page.set_option(faved_at_max: '1/9/2004', faved_at_min: '1/2/2004')
      @page.pause
      @page.grid_pictures.size.should == 3
    end
  end

  describe "browsing faves from flickr" do
    before :all do
      clear_faved_pictures
      reset_sync_status false
      @page.pause

    end

    after :all do
      add_faved_pictures
      reset_sync_status true
    end

    it 'automatically load faves from flickr when browsing' do
      open_fave_page

      @page.click_right_button
      @page.grid_pictures.size.should == 6
    end
  end

  describe "fave from other user's exhibit page" do

    def open_exhibit
      @page.open "slideshow/exhibit?collector_id=#{Collector.first.id}", true
      @page.enter_slide_mode
      @page.wait_until_fave_ready
    end

    def unfave_exhibit_picture
      open_exhibit
      if(@page.unfave_button.displayed?)
        @page.unfave
      end
    end

    before :all do
      @page.open "slideshow" #for login
      unfave_exhibit_picture
    end

    it "faves other pictures from exhibit page" do
      open_exhibit
      pic_src = @page.slide_picture['src']
      @page.fave
      just_faved?(pic_src).should be_true
    end

  end
end