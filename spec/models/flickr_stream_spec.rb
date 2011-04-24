require 'spec_helper'
require 'flickraw'

describe FlickrStream do

  before do
    @flickr_stream_init_args = {:user_id => 'a_user_id', collector: Factory(:collector)}
  end

  describe "class" do

    before do
      stub_flickr(FlickrStream, :people).stub!(:getInfo).and_return(mock(username: 'a_username', photosurl: 'http://flickr/a_usrname'))
    end

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

      it "should sync all streams fromt the collector if the collector is given" do
        collector = Factory(:collector)
        stream = Factory(:fave_stream, :user_id => Factory.next(:user_id), collector: collector)
        stream.stub!(:sync).and_return 1
        Factory(:fave_stream, :user_id => Factory.next(:user_id))
        FlickrStream.should_receive(:collected_by).with(collector).and_return([stream])
        FlickrStream.sync_all(collector)

      end
    end

    describe "#import" do
      it "should import from the array of attributes hashes" do
        import_data = [{'user_id' => 'a_user_id', 'type' => 'FaveStream'}]
        FlickrStream.import(import_data, Factory(:collector))
        stream = FlickrStream.all.first
        stream.class.should == FaveStream
        stream.user_id.should == 'a_user_id'
      end

      it "should not reimport if the stream is already subscribed by the same collector" do
        collector = Factory(:collector)
        stream_args = {'user_id' => 'a_user_id', 'type' => 'FaveStream', collector: collector}
        FlickrStream.build(stream_args).save!
        FlickrStream.import( [stream_args], collector)
        FlickrStream.count.should == 1
      end

      it "should still import if the stream is subscribed by another collector" do
        stream_args = {'user_id' => 'a_user_id', 'type' => 'FaveStream', collector: Factory(:collector)}
        FlickrStream.build(stream_args).save!
        FlickrStream.import( [stream_args], Factory(:collector))
        FlickrStream.count.should == 2
      end

      it "should import the streams for the collector passed in" do
        collector = Factory(:collector)
        a_different_collector_id = collector.id + 1000
        import_data = [{'collector_id' => a_different_collector_id, 'user_id' => 'a_user_id', 'type' => 'FaveStream'}]
        FlickrStream.import(import_data, collector)
        FlickrStream.first.collector.should == collector
      end
    end


    describe "#unviewed" do
      it "should return the stream which is not viewed at all" do
        stream = Factory(:fave_stream)
        Factory(:picture).synced_by(stream)
        FlickrStream.unviewed.should == stream
      end

      it "should not return the stream which is viewed once" do
        stream = Factory(:fave_stream)
        Factory(:picture).synced_by(stream)
        Factory(:picture).synced_by(stream).get_viewed
        FlickrStream.unviewed.should be_nil
      end

      it "should not return stream with no pictures at all" do
        Factory(:fave_stream)
        FlickrStream.unviewed.should be_nil
      end

      it "should not return stream with no pictures at all" do
        Factory(:fave_stream)
        FlickrStream.unviewed.should be_nil
      end
    end

    describe "#least_viewed" do
      it "should return the stream which is not viewed at all" do
        stream = Factory(:fave_stream)
        stream2 = Factory(:fave_stream)
        Factory(:picture).synced_by(stream)
        Factory(:picture).synced_by(stream2).get_viewed
        FlickrStream.least_viewed.should == stream
      end

      it "should return the stream which is viewed less than other stream" do
        stream = Factory(:fave_stream)
        stream2 = Factory(:fave_stream)
        Factory(:picture).synced_by(stream)
        Factory(:picture).synced_by(stream).get_viewed
        Factory(:picture).synced_by(stream2).get_viewed
        Factory(:picture).synced_by(stream2).get_viewed
        FlickrStream.least_viewed.should == stream
      end

      it "should be able to change according to the flickstream viewed count" do
        stream = Factory(:fave_stream)
        stream2 = Factory(:fave_stream)

        Factory(:picture).synced_by(stream).get_viewed
        pic1b = Factory(:picture).synced_by(stream)
        pic1c = Factory(:picture).synced_by(stream)
        Factory(:picture).synced_by(stream)
        Factory(:picture).synced_by(stream2).get_viewed
        Factory(:picture).synced_by(stream2).get_viewed
        Factory(:picture).synced_by(stream2)

        FlickrStream.least_viewed.should == stream

        pic1b.get_viewed
        pic1c.get_viewed

        FlickrStream.least_viewed.should == stream2

      end

      it "should not return the stream without any unviewed picture" do
        stream = Factory(:fave_stream)
        Factory(:picture).synced_by(stream).get_viewed
        FlickrStream.least_viewed.should be_nil
      end

      it "should not return viewed stream of a collector different from the one passed in" do
        stream = Factory(:fave_stream, collector: Factory(:collector))
        Factory(:picture).synced_by(stream)
        Factory(:picture).synced_by(stream).get_viewed

        FlickrStream.least_viewed(Factory(:collector)).should be_nil
      end

      it "should not return unviewed stream of a collector different from the one passed in" do
        stream = Factory(:fave_stream, collector: Factory(:collector))
        Factory(:picture).synced_by(stream)

        FlickrStream.least_viewed(Factory(:collector)).should be_nil
      end

    end
  end

  shared_examples_for "All FlickrStreams" do
    describe "#sync" do
      before do
        @flickr_module = stub_flickr(@flickr_stream, @flickr_module_name)
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

      it "should sync up to how many pages it takes to get max_num_of pictures" do
        @flickr_module.should_receive(@flickr_method).and_return([Factory.next(:pic_info)]*FlickrStream::PER_PAGE)
        @flickr_module.should_receive(@flickr_method).
            with(hash_including(page: 2)).and_return([Factory.next(:pic_info)]*FlickrStream::PER_PAGE)
        @flickr_module.should_not_receive(@flickr_method).with(hash_including(page: 3))


        @flickr_stream.sync(nil, 2*FlickrStream::PER_PAGE )
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

      it "should create one picture with multiple linked flickr_streams if the picture get synced by muitiple flickr_streams(from the same collector)" do
        a_pic_info = Factory.next(:pic_info)
        flickr_stream2 = @flickr_stream.class.create!(user_id: 'another_user', collector: @flickr_stream.collector)

        @flickr_module.should_receive(@flickr_method).and_return([a_pic_info])
        @flickr_module.should_receive(@flickr_method).and_return([])
        flickr_module2 = stub_flickr(flickr_stream2, @flickr_module_name)
        flickr_module2.should_receive(@flickr_method).and_return([a_pic_info])
        flickr_module2.should_receive(@flickr_method).and_return([])
        @flickr_stream.sync
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

      it "should add the picture synced to the collector this stream belongs to" do
        a_pic_info =  Factory.next(:pic_info)
        @flickr_module.should_receive(@flickr_method).and_return([a_pic_info])

        @flickr_stream.sync

        @flickr_stream.collector.pictures.size.should == 1
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
        @flickr_stream.add_score(1.month.ago)
        @flickr_stream.monthly_scores[0].score.should == 1
        @flickr_stream.add_score(1.month.ago)
        @flickr_stream.reload.monthly_scores[0].score.should == 2
      end
    end

    describe "#rating" do
      it "should use weighted monthly score" do
        @flickr_stream.add_score(1.month.ago)
        @flickr_stream.score_for(1.month.ago).update_attribute(:num_of_pics, 2)
        @flickr_stream.add_score(4.month.ago)
        @flickr_stream.score_for(4.month.ago).update_attribute(:num_of_pics, 5)
        @flickr_stream.reload
        @flickr_stream.rating.should be_within(0.01).of(0.4) #( 0.5 + (0.2 * 0.5) ) / 1.5
      end
    end

    describe "#star_rating" do

      before do
        @flickr_stream.score_for(1.month.ago).add_num_of_pics(100)
      end

      it "should be 0 for rating 0 - 0.01" do
        @flickr_stream.star_rating.should == 0
      end

      it "should be 1 for rating 0.01 - 0.05" do
        @flickr_stream.add_score(1.month.ago, 1)
        @flickr_stream.star_rating.should == 1
      end

      it "should be 2 for rating 0.05 - 0.1" do
        @flickr_stream.add_score(1.month.ago, 5)
        @flickr_stream.star_rating.should == 2
      end

      it "should be 3 for rating 0.1 - 0.2" do
        @flickr_stream.add_score(1.month.ago, 10)
        @flickr_stream.star_rating.should == 3
      end

      it "should be 4 for rating 0.2 - 0.4 " do
        @flickr_stream.add_score(1.month.ago, 20)
        @flickr_stream.star_rating.should == 4
      end

      it "should be 4 for rating larger than 0.4 " do
        @flickr_stream.add_score(1.month.ago, 40)
        @flickr_stream.star_rating.should == 5
      end

    end

    describe "#bump_rating" do
      it "should bump rating in the most recent two month with ratings" do
        @flickr_stream.star_rating.should == 0
        @flickr_stream.bump_rating
        @flickr_stream.star_rating.should == 1
        @flickr_stream.bump_rating
        @flickr_stream.star_rating.should == 2
      end
    end

    describe "#monthly_scores" do
      it "should order by month from recent to old" do
        @flickr_stream.score_for(Date.new(2000, 4, 1))
        @flickr_stream.score_for(Date.new(2001, 3, 1))
        @flickr_stream.score_for(Date.new(2000, 5, 1))
        @flickr_stream.reload.monthly_scores.map(&:month).should == [3,5,4]
      end

    end

    describe "#destroy" do
      it "should remove pictures from the stream" do
        pic = Factory(:picture)
        stream = Factory(:fave_stream)
        pic.synced_by(stream)
        stream.destroy
        Picture.find_by_id(pic.id).should be_nil
      end

      it "should not remove pictures that is also from other stream" do
        pic = Factory(:picture)
        stream = Factory(:fave_stream)
        pic.synced_by(stream)
        pic.synced_by(Factory(:fave_stream))
        stream.destroy
        Picture.find(pic.id).should be_present
      end

    end

    describe "#flickr" do
      it "should be using the auth_token as the collector" do
        collector = Factory(:collector, auth_token: 'a_token')
        @flickr_stream.collector = collector
        FlickRaw::Flickr.should_receive(:new).with('a_token').and_return(:a_fake_flickr)
        @flickr_stream.flickr.should == :a_fake_flickr
      end
    end

  end

  describe FaveStream do
    before do
      @flickr_stream = FaveStream.create(@flickr_stream_init_args)
      @flickr_module_name = :favorites
      @flickr_method = :getList
      @related_date_field = :min_fave_date
    end

    it_should_behave_like 'All FlickrStreams'

  end

  describe "FaveStream#Sync" do
     it "should create a new picture if the pic from flickr is already synced by a stream of another collector" do
        a_pic_info =  Factory.next(:pic_info)

        stream1 = Factory(:fave_stream, collector: Factory(:collector))
        stream1.stub(:get_pic_up_to).and_return([a_pic_info])
        stream1.sync
        Picture.count.should == 1

        collector = Factory(:collector)
        stream2 = Factory(:fave_stream, collector: collector)
        stream2.stub(:get_pic_up_to).and_return([a_pic_info])

        stream2.sync

        Picture.count.should == 2
        collector.reload.pictures.size.should == 1

      end
  end

  describe UploadStream do
    before do
      @flickr_stream = UploadStream.create(@flickr_stream_init_args)
      @flickr_module_name = :people
      @flickr_method = :getPhotos
      @related_date_field = :min_upload_date

    end

    it_should_behave_like 'All FlickrStreams'


  end

end