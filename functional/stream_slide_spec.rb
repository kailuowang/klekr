require File.expand_path('../spec_helper', __FILE__)

describe "Stream slide page" do
  include Functional::DataUtil

  before :all do
    @page = Functional::FlickrStreamSlidePage.new
    @stream = collector.flickr_streams.type('UploadStream').where(user_id: '45425373@N00').first
    @stream.sync if @stream.pictures.empty?
  end

  after :all do
    @page.close
  end


  describe 'faving pictures in flickr stream' do
    before :all do
      @fave_page = Functional::FavePage.new
      clear_faved_pictures({}, test_collector)
    end

    after :all do
      @fave_page.close
    end

    it 'can fave pictures when logged in' do
      @page.open_authenticated(@stream.id, as_test_collector: true)
      @page.enter_slide_mode
      src = @page.slide_picture['src']
      @page.wait_until_fave_ready
      @page.fave(1)
      @page.pause(1)
      @fave_page.open as_test_collector: true
      @fave_page.just_faved?(src).should be_true
    end

    it 'can direct to the same picture when clicked on fave reminder' do
      @page.log_out
      @page.open_anonymously(@stream)
      @page.should_not be_logged_in

      @page.enter_slide_mode
      src = @page.slide_picture['src']

      @page.click_fave_login

      @page.wait_until do
        @page.slide_picture['src'] == src
        @page.should be_logged_in
      end

    end

  end

  context 'flickr stream operations' do
    before :all do
      test_collector.flickr_streams.destroy_all
      test_collector.pictures.destroy_all
    end

    shared_examples "normal browsing" do
      it 'displays stranger photographers pictures from flickr' do
        @page.open_by_user(@stream.user_id, as_test_collector: true)
        @page.grid_pictures_ids.should be_present
      end

      it 'should not increase the number of unviewd pictures' do
        original_count = test_collector.pictures.count
        @page.open_by_user(@stream.user_id, as_test_collector: true)
        test_collector.pictures.count.should == original_count
      end

      it 'displayes other collectors flickr_stream' do
        @page.open_anonymously( @stream, as_test_collector: true)
        @page.grid_pictures_ids.should be_present
      end
    end


    context 'without login' do
      before :all do
        @page.log_out
      end

      it_behaves_like 'normal browsing'
    end

    context 'when logged in' do
      before :all do
        @page.open_authenticated(@stream.id)
      end
      it_behaves_like 'normal browsing'
    end

    context 'subscribing to stranger stream' do

      before :each do
        @page.log_out
      end

      def should_be_able_to_subscribe
        @page.subscribe
        @page.wait_until do
          @page.unsubscribe_btn.displayed?
        end
      end

      it "subscribe when not logged in" do
        @page.open_by_user(@stream.user_id, as_test_collector: true)
        should_be_able_to_subscribe
      end

      it "can unsubscribe" do
        @stream.subscribe
        @page.open_authenticated(@stream.id)
        @page.unsubscribe
        @page.wait_until do
          @page.subscribe_btn.displayed?
        end
      end

      it "subscribe when logged in" do
        @stream.unsubscribe
        @page.open_authenticated(@stream.id)
        should_be_able_to_subscribe
      end
    end


  end
end