require 'spec_helper'

describe Collectr::FaveImporter do

  def mock_fave_info(*opts)
    opts = [{}] if opts.blank?
    mock(person: opts.map do |opt|
        opt[:collector] = FactoryGirl.create(:collector) unless opt[:collector]
        opt[:fave_date] = 1423.days.ago unless opt[:fave_date]
        mock(nsid: opt[:collector].user_id, favedate: opt[:fave_date].to_i)
      end
    )
  end

  before do
    @retriever = mock(:retriever)
    @retriever.stub!(:get).and_return(2.pics)
    Collectr::FlickrPictureRetriever.stub!(:new).and_return(@retriever)
    @importer = Collectr::FaveImporter.new(FactoryGirl.create(:collector), 1.week.ago)

    @flickr = stub_flickr(@importer, :photos)
    @flickr.stub(:getFavorites).and_return(mock_fave_info(collector: @importer.collector))
  end

  describe "#import" do

    it "creates pictures in DB retrieved from flickr" do
      @retriever.should_receive(:get).and_return(2.pics)
      @importer.import(3)
      Picture.count.should == 2
    end

    it "does not create streams in DB when retrieving from flickr" do
      @importer.import(2)
      FlickrStream.count.should == 0
    end

    it "does not set stream to newly retrieved pictures " do
      @retriever.stub!(:get).and_return(1.pic)
      results = @importer.import(1)
      results.first.flickr_streams.should be_blank
    end

    it "sets the newly retrieved pictures rating to 1" do
      @retriever.stub!(:get).and_return(1.pic)
      results = @importer.import(1)
      results.first.rating.should == 1
    end

    it "retrieve pictures from flickr with faved_date earlier than the before date" do
      @retriever.should_receive(:get).with(1, 1, nil, @importer.faved_before)
      @importer.import(1)
    end

    context 'viewed' do
      it "mark new fave imported as viewed" do
         @flickr.should_receive(:getFavorites).with(hash_including(page: 1)).and_return(mock_fave_info)
         @importer.import(1).last.should be_viewed
       end

    end
    context "faved_at" do
      it "use flickr to get the earlest faved date from the result" do
        _, last_pic = (pics = 2.pics)
        @retriever.stub!(:get).and_return(pics)
        earlest_faved = 3.days.ago
        @flickr.should_receive(:getFavorites).
            with(hash_including(photo_id: last_pic.id, secret: last_pic.secret)).
            and_return(mock_fave_info(collector: @importer.collector,fave_date: earlest_faved))
        @importer.import(2).last.faved_at.to_i.should == earlest_faved.to_i
      end

      it "use the fave_date faved by the current collector" do
        earlest_faved = 2.days.ago
        faves_info = mock_fave_info({}, {collector: @importer.collector, fave_date: earlest_faved}, {})
        @flickr.should_receive(:getFavorites).and_return(faves_info)
        @importer.import(1).last.faved_at.to_i.should == earlest_faved.to_i
      end

      it "go through multiple pages until find the fave_info for the collector" do
        fave_date = 1.day.ago
        @flickr.should_receive(:getFavorites).with(hash_including(page: 1)).and_return(mock_fave_info)
        @flickr.should_receive(:getFavorites).with(hash_including(page: 2)).and_return(mock_fave_info)
        @flickr.should_receive(:getFavorites).with(hash_including(page: 3)).and_return(mock_fave_info(collector: @importer.collector, fave_date: fave_date))
        @importer.import(1).last.faved_at.to_i.should == fave_date.to_i
      end

      it "gives up when exhaust the fave_infos" do
        @flickr.should_receive(:getFavorites).with(hash_including(page: 1)).and_return(mock_fave_info)
        @flickr.should_receive(:getFavorites).with(hash_including(page: 2)).and_return(mock(person:[]))
        @flickr.should_not_receive(:getFavorites).with(hash_including(page: 3))
        Rails.logger.should_receive(:error)
        @importer.import(1)
      end

      it "retains the fave_date sequence" do
        pics = 3.pics
        @retriever.stub!(:get).and_return(pics)
        @importer.import(3)
        Picture.faved_by(@importer.collector, {min_rating: 1}, 1, 3).map(&:title).should == pics.map(&:title)
      end

      it 'does not do antything if no pic faved' do
        @retriever.stub!(:get).and_return([])
        @importer.import(3)
        Picture.count.should == 0
      end
    end

  end
end