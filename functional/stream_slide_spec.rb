require File.expand_path('../spec_helper', __FILE__)

describe "Stream slide page" do
  include Functional::DataUtil

  before :all do
    @page = Functional::SlideshowPage.new
  end


  after :all do
    @page.close
  end

  describe 'browsing' do
    before :all do
      @stream = collector.flickr_streams.find { |stream| stream.pictures.many? }
      test_collector.flickr_streams.where(user_id: @stream.user_id).first.try(:destroy)
    end
    it 'displays stranger photographers pictures from flickr' do
      @page.open("users/#{@stream.user_id}", true, test: true)
      @page.grid_pictures_ids.should be_present
    end

  end

end