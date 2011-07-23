require 'spec_helper'

describe Picture do
  describe "class" do
    describe "#find_or_initialize_from_pic_info" do
      it "should be able to create from flickr pic info" do
        pic_info = Factory.next(:pic_info)
        pic_info.stub!(:dateupload).and_return 1297935005
        FlickRaw.should_receive(:url_photopage).with(pic_info).and_return('http://flickr/photo/pic1')
        picture = Picture.find_or_initialize_from_pic_info(pic_info)
        picture.url.should == 'http://flickr/photo/pic1'
        picture.date_upload.should == Time.at(1297935005).to_datetime
        picture.owner_name.should == pic_info.ownername
        picture.pic_info.secret.should == pic_info.secret

      end

      it "should not create duplicate picture for the same collector" do
        collector = Factory(:collector)
        pic_info = Factory.next(:pic_info)
        pic = Picture.find_or_initialize_from_pic_info(pic_info, collector)
        pic.save!
        Picture.find_or_initialize_from_pic_info(pic_info, collector).should == pic
      end
      it "should create duplicate picture for different collectors" do
        pic_info = Factory.next(:pic_info)
        pic = Picture.find_or_initialize_from_pic_info(pic_info, Factory(:collector))
        pic.save!
        Picture.find_or_initialize_from_pic_info(pic_info, Factory(:collector)).should_not == pic
      end
    end

    describe "#reset_stream_ratings" do
      it "should reset all pictures settings to the new ratings of the flickrstream they come from" do
        picture = Factory(:picture)
        stream = Factory(:fave_stream)
        stream.score_for(Date.today).bump
        picture.synced_by(stream)
        picture.stream_rating.should == 1
        stream.score_for(Date.today).bump
        Picture.reset_stream_ratings
        picture.reload.stream_rating.should == 2
      end
    end

    describe "#syned_from" do
      it "should return the list of pictures from that stream" do
        picture = Factory(:picture)
        Factory(:picture)
        stream = Factory(:fave_stream)
        picture.synced_by(stream)
        Picture.syned_from(stream).map(&:id).should == [picture.id]
      end
    end

    describe "#collected_by" do
      it "should return pictures collected by the collector" do
        collector = Factory(:collector)
        pic = Factory(:picture, collector: collector)
        Picture.collected_by(collector).should == [pic]
      end
      it "should not return pictures collected by the collector" do
        Factory(:picture, collector: Factory(:collector))
        Picture.collected_by(Factory(:collector)).should be_empty
      end
    end


    describe "#most_insteresting_for" do

      it "return the latest picture" do
        collector = Factory(:collector)
        Factory(:picture, date_upload: 2.hour.ago, collector: collector)
        pic = Factory(:picture, date_upload: 1.hour.ago, collector: collector)
        Picture.most_interesting_for(collector).should == pic
      end

      it "should redirect to show the picture collected by the current collector" do
        collector = Factory(:collector)
        Factory(:picture, date_upload: 1.hour.ago)
        pic = Factory(:picture, date_upload: 2.hour.ago, collector: collector)
        Picture.most_interesting_for(collector).should == pic
      end

      it "should redirect to show the latest picture that has not been viewed yet" do
        collector = Factory(:collector)

        Factory(:picture, date_upload: 3.hour.ago, :viewed => true, collector: collector)
        pic2 = Factory(:picture, date_upload: 2.hour.ago, collector: collector)
        pic = Factory(:picture, date_upload: 1.hour.ago, :viewed => true, collector: collector)
        pic.get_viewed
        Picture.most_interesting_for(collector).should == pic2
      end
    end
  end

  describe "#fave" do
    it "should add the picture to fave" do
      picture = Factory(:picture, date_upload: DateTime.new(2010, 1, 3))
      stub_flickr(picture, :favorites).should_receive(:add).with(photo_id: picture.pic_info.id)
      picture.fave
    end

    it "should add score to the streams it comes from" do
      picture = Factory(:picture)
      picture.synced_by(Factory(:fave_stream))
      stub_flickr(picture, :favorites).stub!(:add)
      picture.flickr_streams[0].should_receive(:add_score).with(picture.created_at)
      picture.fave
    end

    it "should set rating to 1 when successfully added" do
      picture = Factory(:picture)
      stub_flickr(picture, :favorites).stub!(:add)
      picture.fave
      picture.rating.should == 1
    end

    it "should only try fave it if its not faved already" do
      picture = Factory(:picture, rating: 1)
      stub_flickr(picture, :favorites).should_not_receive(:add)
      picture.fave
    end
  end

  describe "#faved?" do
    it "should return true if rating is larger than 0" do
      Factory(:picture, rating: 1).should be_faved
    end
    it "should return false if rating is 0" do
      Factory(:picture, rating: 0).should_not be_faved
    end
  end

  describe "#synced_by" do
    it "should add the stream's ratings to the stream_rating if it not synced with the stream before" do
      picture = Factory(:picture)
      stream = Factory(:fave_stream)
      stream.stub!(:star_rating).and_return(0.2)
      picture.synced_by(stream)
      picture.stream_rating.should == 0.2
    end
  end

  describe "#get_viewed" do
    it "should update viewed as true" do
      picture = Factory(:picture)
      picture.get_viewed
      picture.should be_viewed
    end

    it "should update all streams's current month num_of_pics if it's viewed the first time" do
      picture = Factory(:picture, date_upload: 2.months.ago)
      stream = Factory(:fave_stream)
      picture.synced_by(stream)

      picture.get_viewed
      stream.score_for(Date.today).num_of_pics.should == 1

    end

    it "should not increas all streams's current month num_of_pics when viewed multiple times " do
      picture = Factory(:picture)
      stream = Factory(:fave_stream)
      picture.synced_by(stream)

      picture.get_viewed
      picture.get_viewed
      stream.score_for(Date.today).num_of_pics.should == 1
    end
  end

  describe "#next_new_pictures" do
    before do
      @collector = Factory(:collector)
    end

    def create_picture(opts)
      Factory(:picture, {collector: @collector}.merge(opts))
    end

    it "should return x number of unviewed pictures and return in a desc order" do
      picture4 = create_picture(date_upload: DateTime.new(2010, 1, 4), viewed: true)
      picture3 = create_picture(date_upload: DateTime.new(2010, 1, 3))
      create_picture(date_upload: DateTime.new(2010, 1, 2), :viewed => true)
      picture1 = create_picture(date_upload: DateTime.new(2010, 1, 1))
      create_picture(date_upload: DateTime.new(2000, 1, 1))
      picture4.next_new_pictures(2).should == [picture3, picture1]
    end

    it "should return x number of unviewed pictures with highest rating" do
      create_picture(stream_rating: 2)
      pic_with_higher_rating = create_picture(stream_rating: 3)
      create_picture(stream_rating: 3).next_new_pictures(1)[0].should == pic_with_higher_rating
    end

    it "should return x number of unviewed pictures with latest date" do
      create_picture(date_upload: 1.month.ago)
      later_pic = create_picture( date_upload: 2.days.ago)
      create_picture(date_upload: 1.day.ago).next_new_pictures(1)[0].should == later_pic
    end

    it "should not include the picture itself" do
      Factory(:picture).next_new_pictures(1).should be_empty
    end

    it "should return pictures by the collector" do
      collector = Factory(:collector)
      pic = create_picture(:collector => collector)
      create_picture(:collector => collector).next_new_pictures(1).should == [pic]
    end

    it "should not return pictures by a different collector" do
      Factory(:picture)
      create_picture(collector: Factory(:collector)).next_new_pictures(1).should be_empty
    end

    it "not return pictures has higher rating than self" do
      create_picture(stream_rating: 2)
      create_picture(stream_rating: 1).next_new_pictures(1).should be_empty
    end

    it "not return pictures later than self" do
      create_picture(date_upload: 1.day.ago)
      create_picture(date_upload: 2.day.ago).next_new_pictures(1).should be_empty
    end

  end

  describe "#flickr_url" do
    it "should return FlickRaw url_z when size is :medium" do
      picture = Factory(:picture)
      FlickRaw.should_receive(:url_z).with(picture.pic_info).and_return('http://flic.kr/a_pic_z.jpg')
      picture.flickr_url(:medium).should == 'http://flic.kr/a_pic_z.jpg?zz=1'

    end

    it "should return FlickRaw url_b when size is :large" do
      picture = Factory(:picture)
      FlickRaw.should_receive(:url_b).with(picture.pic_info).and_return('http://flic.kr/a_pic_z.jpg')
      picture.flickr_url(:large).should == 'http://flic.kr/a_pic_z.jpg'
    end
  end

  describe "#guess_hidden_treasure" do
    it "should return the un-viewed pic from the stream least viewed" do
      stream = Factory(:fave_stream)
      FlickrStream.should_receive(:least_viewed).and_return(stream)

      pic = Factory(:picture)
      pic.synced_by(stream)
      pic2 = Factory(:picture)
      pic2.synced_by(stream)
      pic2.get_viewed


      Factory(:picture).guess_hidden_treasure.id.should == pic.id
    end

    it "should return the pics in upload date desc order" do
      stream = Factory(:fave_stream)
      FlickrStream.should_receive(:least_viewed).and_return(stream)

      Factory(:picture, date_upload: 1.day.ago).synced_by(stream)
      pic = Factory(:picture, date_upload: Date.today)
      pic.synced_by(stream)
      Factory(:picture, date_upload: 2.days.ago).synced_by(stream)

      Factory(:picture).guess_hidden_treasure.id.should == pic.id
    end

  end

end