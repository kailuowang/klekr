require 'spec_helper'
require 'flickraw'

describe FlickrStream do

  before do
    @flickr_stream_init_args = {:user_id => 'a_user_id'}
    flickr.people.stub!(:getInfo).and_return(mock(username: 'a_username'))
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

      it "should store the username" do
        stream = FlickrStream.build(user_id: 'a_user_id', 'type' => 'fave')
        stream.save!
        FlickrStream.first.username.should == 'a_username'
      end
    end
  end

  shared_examples_for "All FlickrStreams" do
    describe "#sync" do
      before do
        @flickr_module.stub!(@flickr_method).and_return([])
      end


      it "should use flickr module with user id to get pictures" do
        a_pic_info = Factory.next(:pic_info)
        another_pic_info = Factory.next(:pic_info)
        @flickr_module.should_receive(@flickr_method).
            with(hash_including(user_id: 'a_user_id')).
            and_return([a_pic_info, another_pic_info])

        @flickr_stream.sync
        Picture.count.should == 2
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

      it "should synced picture should be linked with the stream" do
        a_pic_info = Factory.next(:pic_info)
        @flickr_module.should_receive(@flickr_method).and_return([a_pic_info])
        @flickr_stream.sync
        Picture.first.flickr_streams.should include(@flickr_stream)
      end

      it "should not duplicate syncage when syncing the same picture" do
        a_pic_info = Factory.next(:pic_info)
        @flickr_module.should_receive(@flickr_method).and_return([a_pic_info])
        @flickr_stream.sync
        @flickr_stream.sync
        Syncage.count.should == 1
      end

      it "should create one picture with multiple linked flickr_streams if the picture get synced by muitiple flickr_stream" do
        a_pic_info = Factory.next(:pic_info)
        @flickr_module.stub!(@flickr_method).and_return([a_pic_info])
        flickr_stream2 = @flickr_stream.class.create!(user_id: 'another_user')
        @flickr_stream.sync
        flickr_stream2.sync
        Picture.count.should == 1
        Picture.first.flickr_streams.should == [@flickr_stream, flickr_stream2]
      end

    end
  end

  describe FaveStream do
    before do
      @flickr_stream = FaveStream.create(@flickr_stream_init_args)
      @flickr_module = flickr.favorites
      @flickr_method = :getList
    end

    it_should_behave_like 'All FlickrStreams'

  end

  describe UploadStream do
    before do
      @flickr_stream = UploadStream.create(@flickr_stream_init_args)
      @flickr_module = flickr.people
      @flickr_method = :getPhotos
    end

    it_should_behave_like 'All FlickrStreams'

  end

end