require 'spec_helper'
require 'flickraw'

describe FlickrStream do

  before do
    @flickr_stream_init_args = {:user_id => 'a_user_id'}
    flickr.people.stub!(:getInfo).and_return(mock(username: 'a_username', photosurl: 'http://flickr/a_usrname'))
  end

  describe "class" do
    describe "#build" do
      it "should create a FaveStream when arg['type'] is 'fave' " do
        stream = FlickrStream.build(user_id: 'a_user_id', 'type' => 'FaveStream')
        stream.class.should == FaveStream
        stream.user_id.should == 'a_user_id'
      end

      it "should create a UploadStream when arg['type'] is 'UploadStream' " do
        FlickrStream.build(user_id: 'a_user_id', 'type' => 'UploadStream').class.should == UploadStream
      end

      it "should store the username" do
        stream = FlickrStream.build(user_id: 'a_user_id', 'type' => 'FaveStream')
        stream.save!
        FlickrStream.first.username.should == 'a_username'
      end
    end

    describe "#sync_all" do
      it "should sync all streams and return the total number of pictures synced" do
        stream1 = Factory(:fave_stream, :user_id => Factory.next(:user_id))
        stream2 = Factory(:fave_stream, :user_id => Factory.next(:user_id))
        stream1.stub!(:sync).and_return 1
        stream2.stub!(:sync).and_return 2
        FlickrStream.stub!(:all).and_return [stream1, stream2]
        FlickrStream.sync_all.should == 3
      end
    end

    describe "#import" do
      it "should import from the array of attributes hashes" do
        import_data = [{'user_id' => 'a_user_id', 'type' => 'FaveStream'}]
        FlickrStream.import(import_data)
        stream = FlickrStream.all.first
        stream.class.should == FaveStream
        stream.user_id.should == 'a_user_id'
      end

      it "should not reimport if the stream is already subscribed" do

        stream_args = {'user_id' => 'a_user_id', 'type' => 'FaveStream'}
        FlickrStream.build(stream_args).save!
        FlickrStream.import( [stream_args])
        FlickrStream.count.should == 1
      end
    end
  end

  shared_examples_for "All FlickrStreams" do
    describe "#sync" do
      before do
        @flickr_module.stub!(@flickr_method).and_return([])
      end


      it "should use flickr module with user id to get pictures and return the number of pictures synced" do
        a_pic_info = Factory.next(:pic_info)
        another_pic_info = Factory.next(:pic_info)
        @flickr_module.should_receive(@flickr_method).
            with(hash_including(user_id: 'a_user_id')).
            and_return([a_pic_info, another_pic_info])

        @flickr_stream.sync.should == 2
        Picture.count.should == 2
      end

      it "should sync with owner_name and date_upload" do
        @flickr_module.should_receive(@flickr_method).
            with(hash_including(extras: 'date_upload, owner_name')).and_return([])

        @flickr_stream.sync
      end

      it "should sync up to howmany pages it takes to get to the last sync date of the pictures" do
        @flickr_module.should_receive(@flickr_method).and_return([Factory.next(:pic_info)])
        @flickr_module.should_receive(@flickr_method).
            with(hash_including(page: 2)).and_return([Factory.next(:pic_info)])
        @flickr_module.should_receive(@flickr_method).
            with(hash_including(page: 3)).and_return([])
        @flickr_module.should_not_receive(@flickr_method).with(hash_including(page: 4))


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
        @flickr_module.should_receive(@flickr_method).and_return([a_pic_info])
        flickr_stream2 = @flickr_stream.class.create!(user_id: 'another_user')
        @flickr_stream.sync
        @flickr_module.should_receive(@flickr_method).and_return([a_pic_info])
        flickr_stream2.sync
        Picture.count.should == 1
        Picture.first.flickr_streams.should == [@flickr_stream, flickr_stream2]
      end

      it "should only sync photos faved upto the last sync time" do
        last_sync = DateTime.new(2010,1,2)
        @flickr_stream.last_sync = DateTime.new(2010,1,2)
        @flickr_module.should_receive(@flickr_method).with(hash_including(@related_date_field => last_sync.to_i)).and_return([])
        @flickr_stream.sync
      end

      it "should only sync photos faved upto the 1 month ago if it's the first time sync" do
        @flickr_stream.last_sync = nil
        @flickr_module.should_receive(@flickr_method).with(hash_including(@related_date_field => 1.month.ago.to_i)).and_return([])
        @flickr_stream.sync
      end

      it "should update num_of_picture for the current monthly score" do
        @flickr_module.should_receive(@flickr_method).and_return([Factory.next(:pic_info),Factory.next(:pic_info)])
        @flickr_stream.sync
        MonthlyScore.by_month_stream(Date.today, @flickr_stream).first.num_of_pics.should == 2
      end
    end

    describe "#add_score" do
      it "should ensure that a monthly score for related date is created for the stream" do
        @flickr_stream.add_score(Date.new(2010,10,2 ))
        @flickr_stream.monthly_scores.count.should == 1
        @flickr_stream.monthly_scores[0].year.should == 2010
        @flickr_stream.monthly_scores[0].month.should == 10
      end

      it "should add score to the current monthly score" do
        @flickr_stream.add_score(Date.today)
        @flickr_stream.monthly_scores[0].score.should == 1
        @flickr_stream.add_score(Date.today)
        @flickr_stream.reload.monthly_scores[0].score.should == 2
      end
    end

    describe "#rating" do
      it "should use weighted monthly score" do
        @flickr_stream.add_score(Date.today)
        @flickr_stream.score_for(Date.today).update_attribute(:num_of_pics, 2)
        @flickr_stream.add_score(4.month.ago)
        @flickr_stream.score_for(4.month.ago).update_attribute(:num_of_pics, 5)
        @flickr_stream.reload
        @flickr_stream.rating.should be_close(0.4, 0.01) #( 0.5 + (0.2 * 0.5) ) / 1.5
      end
    end
  end

  describe FaveStream do
    before do
      @flickr_stream = FaveStream.create(@flickr_stream_init_args)
      @flickr_module = flickr.favorites
      @flickr_method = :getList
      @related_date_field = :min_fave_date
    end

    it_should_behave_like 'All FlickrStreams'

  end

  describe UploadStream do
    before do
      @flickr_stream = UploadStream.create(@flickr_stream_init_args)
      @flickr_module = flickr.people
      @flickr_method = :getPhotos
      @related_date_field = :min_upload_date

    end

    it_should_behave_like 'All FlickrStreams'


  end

end