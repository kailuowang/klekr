require 'spec_helper'

describe Collector do
  before do
    @collector = Factory(:collector)
    @retriever = mock(:retriever)
    @retriever.stub!(:get).and_return([])
    Collectr::FlickrPictureRetriever.stub!(:new).and_return(@retriever)
  end

  describe "#collection" do
    context "get faved photos from DB" do
      it "return faved picture in the DB first" do
        @retriever.should_not_receive(:get)
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
        @retriever.should_receive(:get).with(2, 1, anything, anything).and_return(2.pics)
        Factory(:picture, collector: @collector, rating: 1)
        results = @collector.collection(3, 1)
        results.size.should == 3
      end

      it "does not start to retrieve from flickr if faves in DB is exhausted and mini rating filter is set to larger than 1" do
        @retriever.should_not_receive(:get)
        @collector.collection(2, 1, min_rating: 2)
      end

      it "does not create streams in DB when retrieving from flickr" do
        @collector.collection(2, 1)
        FlickrStream.count.should == 0
      end

      it "does not set stream to newly retrieved pictures " do
        @retriever.stub!(:get).and_return(1.pic)
        results = @collector.collection(1, 1)
        results.first.flickr_streams.should be_blank
      end

      it "sets the newly retrieved pictures rating to 1" do
        @retriever.stub!(:get).and_return(1.pic)
        results = @collector.collection(1, 1)
        results.first.rating.should == 1
      end

      it "retrieve pictures from flickr with faved_date earlier than the earlest in the DB" do
        earlest_faved = 1.month.ago
        Factory(:picture, collector: @collector, rating: 1, faved_at: earlest_faved)
        Factory(:picture, collector: @collector, rating: 1, faved_at: 1.week.ago)
        @retriever.should_receive(:get).with(1,1, nil, earlest_faved)
        @collector.collection(3,1)
      end

      it "sets the faved_at from the flickr" do
        pic = 1.pic.first
        @retriever.stub!(:get).and_return([pic])
        results = @collector.collection(1,1)
        results.first.faved_at.should ==  Time.at(pic.date_faved.to_i).to_datetime
      end
    end
  end
end