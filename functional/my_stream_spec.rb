require File.expand_path('../spec_helper', __FILE__)

describe "My stream page" do
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

  describe "tracking progress" do
    before :all do
      reset_viewed_pictures
    end

    describe 'in slide mode' do
      it "marks the picture as viewed after going to the next" do
        pic_src = @page.slide_picture['src']
        @page.click_right_button
        @page.open
        @page.slide_picture['src'].should_not == pic_src
      end

      it "marks the picture as viewed after enter the grid mode from that picture" do
        pic_src = @page.slide_picture['src']
        @page.wait_until { @page.slide_picture.displayed? }
        @page.slide_picture.click
        @page.pause
        @page.open
        @page.slide_picture['src'].should_not == pic_src
      end
    end

    describe 'in grid mode' do
      it "mark the all pictures in the current page as viewed when navigate to the next page" do
        @page.enter_grid_mode
        pic_ids_in_page = @page.grid_pictures_ids
        @page.grid_next_page
        @page.pause 1
        @page.open
        pic_ids_in_page.should_not include(@page.slide_picture_id)
      end

    end
  end

  describe 'with filter options' do

    before :all do
      reset_viewed_pictures
      reset_viewed_upload_pictures
    end

    it 'can display all photos in date order' do
      last_picture = latest_viewed_picture
      @page.set_option(viewed_filter: true)
      @page.enter_slide_mode
      @page.slide_picture_id.should == last_picture.id.to_s
    end

    it 'can display only upload streams' do
      @page.set_option(type_filter: true)
      @page.grid_pictures_ids.each do |id|
        Picture.find(id).flickr_streams.any? do |stream|
          stream.is_a? UploadStream
        end.should be_true
      end
    end
  end
end