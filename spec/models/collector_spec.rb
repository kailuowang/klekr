require 'spec_helper'

describe Collector do
  before do
    stub_retriever
  end

  describe '.find_or_create_by_auth' do
    it 'does not create a new collector or stream if there is already one with the same user id' do
      collector = create(:collector)
      user_id = collector.user_id
      
      # Create auth hash that matches Collector model expectations
      auth = {
        user: {
          'id' => user_id,
          'username' => 'test_user'
        },
        access_token: 'test_token',
        access_secret: 'test_secret'
      }
      
      expect(Collector.find_or_create_by_auth(auth)).to eq(collector)
      expect(FlickrStream.count).to eq(0)
    end
  end

  describe "#collection" do
    before do
      @collector = create(:collector)
      @importer = double(:importer)
      allow(@importer).to receive(:import).and_return([])
      allow(Collectr::FaveImporter).to receive(:new).and_return(@importer)
    end

    context "get faved photos from DB" do
      it "return faved picture in the DB first" do
        expect(@importer).not_to receive(:import)
        pic1 = create(:picture, collector: @collector, rating: 1)
        pic2 = create(:picture, collector: @collector, rating: 1)
        expect(@collector.collection(2, 1)).to include(pic1, pic2)
      end

      it "does not include non-faved picture" do
        pic = create(:picture, collector: @collector, rating: 0)
        expect(@collector.collection(2, 1)).not_to include(pic)
      end
    end

    context "get faved photos from flickr" do
      it "start to retrieve from flickr if faves in DB is exhausted and mini rating filter is not set" do
        expect(@importer).to receive(:import).with(2).and_return(2.pictures)
        create(:picture, collector: @collector, rating: 1)
        results = @collector.collection(3, 1)
        expect(results.size).to eq(3)
      end

      it "does not start to retrieve from flickr if faves in DB is exhausted and mini rating filter is set to larger than 1" do
        expect(@importer).not_to receive(:import)
        @collector.collection(2, 1, min_rating: 2)
      end

      it "retrieve pictures from flickr faved before the earlest from the DB" do
        earlest_faved = 1.month.ago
        create(:picture, collector: @collector, rating: 1, faved_at: earlest_faved)
        create(:picture, collector: @collector, rating: 1, faved_at: 1.week.ago)
        
        expect(Collectr::FaveImporter).to receive(:new).with(@collector, earlest_faved - 5).and_return(@importer)
        @collector.collection(3, 1)
      end
    end
  end

  describe "#collection_opts" do
    it 'should translate params into fave opts' do
      collector = create(:collector)
      # Need to use string keys since Rails params hash would have string keys
      expect(collector.collection_opts({'min_rating' => '2'})).to eq({min_rating: 2})
    end
  end
end