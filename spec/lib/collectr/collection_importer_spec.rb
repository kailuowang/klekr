describe Collectr::CollectionImporter do
  before do
    @collector = Factory(:collector)
    @importer = Collectr::CollectionImporter.new(@collector)
    @retriever = mock(:retriever)
    Collectr::FlickrPictureRetriever.stub!(:new).and_return(@retriever)
  end

  describe "#import" do
    it "imports picture without saving new stream" do
      @retriever.stub!(:get).and_return([])
      @importer.import
      FlickrStream.count.should == 0
    end

    it "imports picture without setting up the stream connection" do
      @retriever.stub!(:get).and_return([Factory.next(:pic_info)])
      @importer.import
      Picture.all.first.flickr_streams.should be_blank
    end
  end
end