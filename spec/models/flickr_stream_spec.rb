require 'spec_helper'
require 'flickraw'

describe FlickrStream do

  before do
    @flickr_stream_init_args = {user_id: 'a_user_id', collector: FactoryGirl.create(:collector), collecting: true}
  end

  describe "class" do

    before do
      stub_flickr(FlickrStream, :people).stub!(:getInfo).and_return(mock(username: 'a_username', photosurl: 'http://flickr/a_usrname'))
    end

    describe "#create" do
      it "should create a FaveStream when arg['type'] is 'fave' " do
        stream = FlickrStream.create_type(user_id: 'a_user_id', 'type' => 'FaveStream')
        stream.class.should == FaveStream
        stream.user_id.should == 'a_user_id'
      end

      it "should create a UploadStream when arg['type'] is 'UploadStream' " do
        FlickrStream.create_type(user_id: 'a_user_id', 'type' => 'UploadStream').class.should == UploadStream
      end

      it "should store the username" do
        FlickrStream.create_type(user_id: 'a_user_id', 'type' => 'FaveStream')
        FlickrStream.first.username.should == 'a_username'
      end

      it "throws error if type unknown" do
        lambda{ FlickrStream.create_type(user_id: 'some id')}.should raise_error
      end
    end

    describe "#find_or_create" do
      it "creates one stream " do
        collector = FactoryGirl.create(:collector)
        FlickrStream.find_or_create(user_id: 'a_user_id', collector: collector, type: 'UploadStream')
        UploadStream.count.should == 1
      end

      it "creates a stream that is not collecting if the stream does not exist yet" do
        collector = FactoryGirl.create(:collector)
        FactoryGirl.create(:fave_stream, user_id: 'a_user_id', collector: collector)
        result = FlickrStream.find_or_create(user_id: 'a_user_id', collector: collector, type: 'UploadStream')
        stream = UploadStream.all.first
        result.should == stream
        stream.should_not be_collecting
      end

      it "return an existing one with the same user id and collector" do
        collector = FactoryGirl.create(:collector)
        stream = FactoryGirl.create(:fave_stream, user_id: 'a_user_id', collector: collector)
        FlickrStream.find_or_create(user_id: 'a_user_id', collector: collector, type: 'FaveStream').should == stream
        stream.reload.should be_collecting
      end


    end

    describe "#sync_all" do
      def create_stream(opts)
        stream = FactoryGirl.create(:fave_stream, opts)
        stub_flickr(stream, :favorites).stub!(:getList).and_return([])
        stream
      end

      it "should sync all streams and return the total number of pictures synced" do
        stream1 = FactoryGirl.create(:fave_stream)
        stream2 = FactoryGirl.create(:fave_stream)
        stream1.stub!(:sync).and_return 1
        stream2.stub!(:sync).and_return 2
        FlickrStream.stub(:get_streams_to_sync).and_return [stream1, stream2]
        FlickrStream.sync_all[:total_pictures_synced].should == 3
      end

      it "sync streams from the collector if the collector is given" do
        collector = FactoryGirl.create(:collector)
        stream = create_stream(collector: collector)

        FlickrStream.sync_all(collector: collector)
        stream.reload.last_sync.should be_present
      end

      it "not sync streams from other collector if the collector is given" do
        stream = FactoryGirl.create(:fave_stream, collector: FactoryGirl.create(:collector))
        FlickrStream.sync_all(collector: FactoryGirl.create(:collector))

        stream.reload.last_sync.should be_blank
      end

      it "sync the streams whose collecting? is true" do
        collecting_stream = create_stream(collecting: true )

        FlickrStream.sync_all
        collecting_stream.reload.last_sync.should be_present
      end

      it "does not sync the streams whose collecting? is false" do
        notcollecting_stream = FactoryGirl.create(:fave_stream, collecting: false)
        FlickrStream.sync_all
        notcollecting_stream.reload.last_sync.should be_blank
      end

      it "does not sync the streams already synced within range" do
        recent_sync = 20.seconds.ago
        recently_synced_stream = create_stream( last_sync: recent_sync)
        unsynced_stream = create_stream(last_sync: 10.minutes.ago)
        FlickrStream.sync_all(synced_before: 1.minute.ago)

        recently_synced_stream.reload.last_sync.should == recent_sync
        unsynced_stream.reload.last_sync.to_f.should be_within(1.5).of(DateTime.now.to_f)
      end

    end

    describe "#import" do
      it "should import from the array of attributes hashes" do
        import_data = [{'user_id' => 'a_user_id', 'type' => 'FaveStream'}]
        FlickrStream.import(import_data, FactoryGirl.create(:collector))
        stream = FlickrStream.all.first
        stream.class.should == FaveStream
        stream.user_id.should == 'a_user_id'
      end

      it "should not reimport if the stream is already subscribed by the same collector" do
        collector = FactoryGirl.create(:collector)
        stream_args = {'user_id' => 'a_user_id', 'type' => 'FaveStream', collector: collector}
        FlickrStream.create_type(stream_args)
        FlickrStream.import( [stream_args], collector)
        FlickrStream.count.should == 1
      end

      it "should still import if the stream is subscribed by another collector" do
        stream_args = {'user_id' => 'a_user_id', 'type' => 'FaveStream', collector: FactoryGirl.create(:collector)}
        FlickrStream.create_type(stream_args)
        FlickrStream.import([stream_args], FactoryGirl.create(:collector))
        FlickrStream.count.should == 2
      end

      it "should import the streams for the collector passed in" do
        collector = FactoryGirl.create(:collector)
        a_different_collector_id = collector.id + 1000
        import_data = [{'collector_id' => a_different_collector_id, 'user_id' => 'a_user_id', 'type' => 'FaveStream'}]
        FlickrStream.import(import_data, collector)
        FlickrStream.first.collector.should == collector
      end
    end


    describe "#unviewed" do
      it "should return the stream which is not viewed at all" do
        stream = FactoryGirl.create(:fave_stream)
        FactoryGirl.create(:picture).synced_by(stream)
        FlickrStream.unviewed.should == stream
      end

      it "should not return the stream which is viewed once" do
        stream = FactoryGirl.create(:fave_stream)
        FactoryGirl.create(:picture).synced_by(stream)
        FactoryGirl.create(:picture).synced_by(stream).get_viewed
        FlickrStream.unviewed.should be_nil
      end

      it "should not return stream with no pictures at all" do
        FactoryGirl.create(:fave_stream)
        FlickrStream.unviewed.should be_nil
      end

      it "should not return stream with no pictures at all" do
        FactoryGirl.create(:fave_stream)
        FlickrStream.unviewed.should be_nil
      end
    end

    describe "#least_viewed" do
      it "should return the stream which is not viewed at all" do
        stream = FactoryGirl.create(:fave_stream)
        stream2 = FactoryGirl.create(:fave_stream)
        FactoryGirl.create(:picture).synced_by(stream)
        FactoryGirl.create(:picture).synced_by(stream2).get_viewed
        FlickrStream.least_viewed.should == stream
      end

      it "should return the stream which is viewed less than other stream" do
        stream = FactoryGirl.create(:fave_stream)
        stream2 = FactoryGirl.create(:fave_stream)
        FactoryGirl.create(:picture).synced_by(stream)
        FactoryGirl.create(:picture).synced_by(stream).get_viewed
        FactoryGirl.create(:picture).synced_by(stream2).get_viewed
        FactoryGirl.create(:picture).synced_by(stream2).get_viewed
        FlickrStream.least_viewed.should == stream
      end

      it "should be able to change according to the flickstream viewed count" do
        stream = FactoryGirl.create(:fave_stream)
        stream2 = FactoryGirl.create(:fave_stream)

        FactoryGirl.create(:picture).synced_by(stream).get_viewed
        pic1b = FactoryGirl.create(:picture).synced_by(stream)
        pic1c = FactoryGirl.create(:picture).synced_by(stream)
        FactoryGirl.create(:picture).synced_by(stream)
        FactoryGirl.create(:picture).synced_by(stream2).get_viewed
        FactoryGirl.create(:picture).synced_by(stream2).get_viewed
        FactoryGirl.create(:picture).synced_by(stream2)

        FlickrStream.least_viewed.should == stream

        pic1b.get_viewed
        pic1c.get_viewed

        FlickrStream.least_viewed.should == stream2

      end

      it "should not return the stream without any unviewed picture" do
        stream = FactoryGirl.create(:fave_stream)
        FactoryGirl.create(:picture).synced_by(stream).get_viewed
        FlickrStream.least_viewed.should be_nil
      end

      it "should not return viewed stream of a collector different from the one passed in" do
        stream = FactoryGirl.create(:fave_stream, collector: FactoryGirl.create(:collector))
        FactoryGirl.create(:picture).synced_by(stream)
        FactoryGirl.create(:picture).synced_by(stream).get_viewed

        FlickrStream.least_viewed(FactoryGirl.create(:collector)).should be_nil
      end

      it "should not return unviewed stream of a collector different from the one passed in" do
        stream = FactoryGirl.create(:fave_stream, collector: FactoryGirl.create(:collector))
        FactoryGirl.create(:picture).synced_by(stream)

        FlickrStream.least_viewed(FactoryGirl.create(:collector)).should be_nil
      end

    end
  end

  shared_examples_for "All FlickrStreams" do
    before do
      stub_flickr(FlickrStream, :people).stub!(:getInfo).and_return(mock(username: 'a_username', photosurl: 'http://flickr/a_usrname'))
    end

    describe "#retriever" do
      it "return the retriever of the same collector" do
        collector = FactoryGirl.create(:collector)
        @flickr_stream.collector = collector
        @flickr_stream.retriever.collector.should == collector
      end
    end

    describe "#sync" do
      before do
        @module = stub_flickr(@flickr_stream.retriever, @flickr_module_name)
        @module.stub!(@flickr_method).and_return([])
      end

      it "should only sync photos faved upto the last sync time by default" do
        @flickr_stream.last_sync = DateTime.new(2010,1,2)
        @flickr_stream.retriever.should_receive(:get_all).with(@flickr_stream.last_sync, anything).and_return([])
        @flickr_stream.sync
      end

      it "should only sync photos faved upto the 1 month ago if it's the first time sync" do
        @flickr_stream.last_sync = nil
        @flickr_stream.retriever.should_receive(:get_all).with() do |since, _|
          since.to_date.should == 1.month.ago.to_date
        end.and_return([])
        @flickr_stream.sync
      end

      it "should update the last_sync date" do
        @flickr_stream.sync
        @flickr_stream.last_sync.should be_within(0.5).of(DateTime.now)
      end

      it "should synced picture should be linked with the stream" do
        a_pic_info =  FactoryGirl.generate(:pic_info)
        @module.should_receive(@flickr_method).and_return([a_pic_info])
        @flickr_stream.sync
        Picture.first.flickr_streams.should include(@flickr_stream)
      end

      it "should not duplicate syncage when syncing the same picture" do
        a_pic_info =  FactoryGirl.generate(:pic_info)
        @module.stub(@flickr_method).and_return([a_pic_info])
        @flickr_stream.sync(nil,1)
        @flickr_stream.sync(nil,1)
        Syncage.count.should == 1
      end

      it "should create one picture with multiple linked flickr_streams if the picture get synced by muitiple flickr_streams(from the same collector)" do
        a_pic_info =  FactoryGirl.generate(:pic_info)
        stub_retriever([a_pic_info])
        flickr_stream1 = @flickr_stream.class.create!(user_id: 'one_user', collector: @flickr_stream.collector, collecting: true)
        flickr_stream2 = @flickr_stream.class.create!(user_id: 'another_user', collector: @flickr_stream.collector, collecting: true)

        flickr_stream1.sync
        flickr_stream2.sync

        Picture.count.should == 1
        Picture.first.flickr_streams.should == [flickr_stream1, flickr_stream2]
      end

      it "should add the picture synced to the collector this stream belongs to" do
        a_pic_info =   FactoryGirl.generate(:pic_info)
        @module.should_receive(@flickr_method).and_return([a_pic_info])

        @flickr_stream.sync

        @flickr_stream.collector.pictures.size.should == 1
      end



    end

    describe "#get_pictures" do
      before do
        @retriever = mock(get: 3.pics)
        Collectr::FlickrPictureRetriever.stub(:new).and_return(@retriever)
      end

      it "does not save pictures to db when not collecting" do
        @flickr_stream.collecting = false
        @flickr_stream.get_pictures(3)
        Picture.count.should == 0
      end

      it "does not save pictures to db when collecting" do
        @flickr_stream.collecting = true
        @flickr_stream.get_pictures(3)
        Picture.count.should == 0
        @flickr_stream.reload.pictures.count.should == 0
      end
      it "does return pictures when collecting" do
        @flickr_stream.collecting = true
        @flickr_stream.get_pictures(1).first.should be_a(Picture)
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
        @flickr_stream.rating.should be_within(0.01).of(0.333) #( 1 + (1 * 0.5)  ) / (2 + 2.5)
      end
    end

    describe "#star_rating" do

      before do
        @flickr_stream.score_for(1.month.ago).add_num_of_pics_viewed(100)
      end

      it "should be 3 for rating 0.05 - 0.10" do
        @flickr_stream.add_score(1.month.ago, 6)
        @flickr_stream.star_rating.should == 3
      end

    end

    describe "#bump_rating" do
      it "should bump rating in the most recent two month with ratings" do
        @flickr_stream.star_rating.should == 1
        @flickr_stream.bump_rating
        @flickr_stream.star_rating.should == 2
        @flickr_stream.bump_rating
        @flickr_stream.star_rating.should == 3
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
        pic = FactoryGirl.create(:picture)
        stream = FactoryGirl.create(:fave_stream)
        pic.synced_by(stream)
        stream.destroy
        Picture.find_by_id(pic.id).should be_nil
      end

      it "should not remove pictures that is also from other stream" do
        pic = FactoryGirl.create(:picture)
        stream = FactoryGirl.create(:fave_stream)
        pic.synced_by(stream)
        pic.synced_by(FactoryGirl.create(:fave_stream))
        stream.destroy
        Picture.find(pic.id).should be_present
      end

    end

    describe "#flickr" do
      it "should be using the auth_token as the collector" do
        collector = FactoryGirl.create(:collector, access_token: 'a_token', access_secret: 'a_secret')
        @flickr_stream.collector = collector
        Collectr::Flickr::FlickRawFactory.should_receive(:create).with('a_token', 'a_secret').and_return(:a_fake_flickr)
        @flickr_stream.flickr.should == :a_fake_flickr
      end
    end

    describe "mark_all_as_read" do
      it "should mark all unviewed pictures as viewed" do
        pic = FactoryGirl.create(:picture)
        pic.synced_by(@flickr_stream)
        @flickr_stream.mark_all_as_read
        pic.reload.should be_viewed
      end
    end

    describe "alternative_stream" do
      it "return the stream of the same collector and same user but different type" do
        collector = FactoryGirl.create(:collector)
        @flickr_stream.collector = collector
        alternative_stream = @flickr_stream.alternative_stream
        alternative_stream.reload
        alternative_stream.type.should_not == @flickr_stream.type
        alternative_stream.collector.should == collector
        alternative_stream.user_id.should == @flickr_stream.user_id
      end

      it "does not create a new one when there is already existing in db" do
        collector = FactoryGirl.create(:collector)
        @flickr_stream.collector = collector
        @flickr_stream.alternative_stream == @flickr_stream.alternative_stream
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
        a_pic_info =   FactoryGirl.generate(:pic_info)

        stream1 = FactoryGirl.create(:fave_stream, collector: FactoryGirl.create(:collector))
        stream1.stub(:retriever).and_return(stub(:get_all => [a_pic_info]))
        stream1.sync
        Picture.count.should == 1

        collector = FactoryGirl.create(:collector)
        stream2 = FactoryGirl.create(:fave_stream, collector: collector)
        stream2.stub(:retriever).and_return(stub(:get_all => [a_pic_info]))
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