require 'spec_helper'

describe Collectr::FlickrPictureRetriever do

  before do
    @retriever = Collectr::FlickrPictureRetriever.new(module: :favorites, method: :getList, time_field: :fave_date, user_id: 'a_user_id')
    @flickr = stub_flickr(@retriever, :favorites)
  end

  describe "#get" do
    it "should sync with owner_name and date_upload" do
      @flickr.should_receive(:getList).
          with(hash_including(extras: 'date_upload, owner_name, description')).and_return([])

      @retriever.get()
    end
  end

  describe "#get_all" do


    it "should use flickr module with user id to get pictures" do
      @flickr.should_receive(:getList).
          with(hash_including(user_id: 'a_user_id')).
          and_return(2.pics)

      @retriever.get_all(nil, 20).size.should == 2
    end

    it "goes through whatever pages it takes to get to the last since date of the pictures" do
      @flickr.should_receive(:getList).and_return(10.pic)
      @flickr.should_receive(:getList).
          with(hash_including(page: 2)).and_return(10.pic)
      @flickr.should_receive(:getList).
          with(hash_including(page: 3)).and_return([])
      @flickr.should_not_receive(:getList).with(hash_including(page: 4))

      @retriever.get_all(10.days.ago, nil).size.should == 20
    end

    it "goes through whatever pages it takes to get max_num_of pictures when since is not given" do
      page_size = Collectr::FlickrPictureRetriever.flickr_photos_per_page
      @flickr.should_receive(:getList).and_return(page_size.pics)
      @flickr.should_receive(:getList).with(hash_including(page: 2)).and_return(page_size.pics)
      @flickr.should_not_receive(:getList).with(hash_including(page: 3))

      @retriever.get_all(nil, 2 * page_size)
    end

    it "use the since date to get pictures" do
      since = DateTime.new(2010, 1, 2)
      @flickr.should_receive(:getList).with(hash_including(:min_fave_date => since.to_i)).and_return(3.pics)
      @flickr.should_receive(:getList).with(hash_including(page:2)).and_return([])
      @retriever.get_all(since, nil).size.should == 3
    end

  end
end