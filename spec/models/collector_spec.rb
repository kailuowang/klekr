require 'spec_helper'

describe Collector do
  before do
    stub_retriever
  end
  describe '.from_new_user' do
    it "should create a new flickr stream when a default stream user id is set" do
      Settings.stub(:default_stream_userid).and_return('defaultstream_user_id')
      auth = mock( user: mock(
                      nsid: 'auersid',
                      username: 'a new user',
                      fullname: 'newusers full'),
                   token: 'a_token')

      FlickrStream.should_receive(:get_user_from_flickr).with('defaultstream_user_id', anything).
              and_return(mock(username: 'defaultstream username', photosurl: 'someuser url'))
      collector = Collector.from_new_user(auth)
      FlickrStream.first.collector.should == collector
      FlickrStream.first.username.should == 'defaultstream username'
    end
  end

  describe '.find_or_create_by_auth' do
    it 'does not create a new collector or stream if there is already one with the same user id' do
      collector = Factory(:collector)
      user_id = collector.user_id
      Collector.find_or_create_by_auth(mock(user: mock(nsid: user_id))).should == collector
      FlickrStream.count.should == 0
    end
  end

  describe "#collection" do
    before do
      @collector = Factory(:collector)
      @importer = mock(:importer)
      @importer.stub!(:import).and_return([])
      Collectr::FaveImporter.stub!(:new).and_return(@importer)
    end

    context "get faved photos from DB" do
      it "return faved picture in the DB first" do
        @importer.should_not_receive(:import)
        pic1 = Factory(:picture, collector: @collector, rating: 1)
        pic2 = Factory(:picture, collector: @collector, rating: 1)
        @collector.collection(2, 1).should include(pic1, pic2)
      end

      it "does not include non-faved picture" do
        pic = Factory(:picture, collector: @collector, rating: 0)
        @collector.collection(2, 1).should_not include(pic)
      end
    end

    context "get faved photos from flickr" do
      it "start to retrieve from flickr if faves in DB is exhausted and mini rating filter is not set" do
        @importer.should_receive(:import).with(2).and_return(2.pictures)
        Factory(:picture, collector: @collector, rating: 1)
        results = @collector.collection(3, 1)
        results.size.should == 3
      end

      it "does not start to retrieve from flickr if faves in DB is exhausted and mini rating filter is set to larger than 1" do
        @importer.should_not_receive(:import)
        @collector.collection(2, 1, min_rating: 2)
      end

      it "retrieve pictures from flickr faved before the earlest from the DB" do
        earlest_faved = 1.month.ago
        Factory(:picture, collector: @collector, rating: 1, faved_at: earlest_faved)
        Factory(:picture, collector: @collector, rating: 1, faved_at: 1.week.ago)
        Collectr::FaveImporter.should_receive(:new).with(@collector, earlest_faved).and_return(@importer)
        @collector.collection(3, 1)
      end
    end

  end
end