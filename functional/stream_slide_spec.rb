require File.expand_path('../spec_helper', __FILE__)

describe "Stream slide page" do
  include Functional::DataUtil

  before :all do
    @page = Functional::SlideshowPage.new
  end

  after :all do
    @page.close
  end

  describe 'browsing flickr stream' do
    before :all do
      @stream = collector.flickr_streams.find { |stream| stream.pictures.many? }
      test_collector.flickr_streams.destroy_all
      test_collector.pictures.destroy_all
      @fave_page = Functional::FavePage.new
    end

    after :all do
      @fave_page.close
    end

    it 'displays stranger photographers pictures from flickr' do
      @page.open("users/#{@stream.user_id}", true, as_test_collector: true)
      @page.grid_pictures_ids.should be_present
    end

    it 'should not increase the number of unviewd pictures' do
      original_count = test_collector.pictures.count
      @page.open("users/#{@stream.user_id}", true, as_test_collector: true)
      test_collector.pictures.count.should == original_count
    end

    it 'displayes other collectors flickr_stream' do
      @page.open("slideshow/flickr_stream", true, id: @stream.id, as_test_collector: true)
      @page.grid_pictures_ids.should be_present
    end

    it 'can fave pictures' do
      @page.open #make sure it auto login when going to slideshow
      @page.open("slideshow/flickr_stream", true, id: @stream.id, as_test_collector: true)
      @page.enter_slide_mode
      src = @page.slide_picture['src']
      @page.wait_until_fave_ready
      @page.fave(1)

      @fave_page.open as_test_collector: true
      @fave_page.just_faved?(src).should be_true
    end
  end
end