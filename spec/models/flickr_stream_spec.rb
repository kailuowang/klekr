require 'spec_helper'
require 'flickraw'

describe FlickrStream do

  before do
    @flickr_stream_init_args = {:user_id => 'a_user_id'}
  end

  describe "class" do
    describe "#build" do
      it "should create a FaveStream when arg['type'] is 'fave' " do
        stream = FlickrStream.build(user_id: 'a_user_id', 'type' => 'fave')
        stream.class.should == FaveStream
        stream.user_id.should == 'a_user_id'
      end
      it "should create a UploadStream when arg['type'] is 'upload' " do
        FlickrStream.build(user_id: 'a_user_id', 'type' => 'upload').class.should == UploadStream
      end
    end
  end

  shared_examples_for "All FlickrStreams" do
    describe "#sync" do
      before do
        @flickr_module.stub!(@flickr_method).and_return([])
      end


      it "should sync to get pictures from flickr" do
        a_pic_info       = mock
        another_pic_info = mock
        @flickr_module.should_receive(@flickr_method).
                with(hash_including(user_id: 'a_user_id')).
                and_return([a_pic_info, another_pic_info])

        Picture.should_receive(:create_from_pic_info).with(a_pic_info)
        Picture.should_receive(:create_from_pic_info).with(another_pic_info)
        @flickr_stream.sync
      end

      it "should sync with date upload for pictures" do
        @flickr_module.should_receive(@flickr_method).
                with(hash_including(extras: 'date_upload')).
                and_return([])

        @flickr_stream.sync
      end

      it "should update the last_sync date" do
        @flickr_stream.sync
        @flickr_stream.last_sync.should be_within(0.5).of(DateTime.now)
      end

    end
  end

  describe FaveStream do
    before do
      @flickr_stream = FaveStream.new(@flickr_stream_init_args)
      @flickr_module = flickr.favorites
      @flickr_method = :getList
    end

    it_should_behave_like 'All FlickrStreams'

  end

  describe UploadStream do
    before do
      @flickr_stream = UploadStream.new(@flickr_stream_init_args)
      @flickr_module = flickr.people
      @flickr_method = :getPhotos
    end

    it_should_behave_like 'All FlickrStreams'

  end

end