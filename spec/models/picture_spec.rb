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

      it "should not create duplicate picture" do
        pic_info = Factory.next(:pic_info)
        pic = Picture.find_or_initialize_from_pic_info(pic_info)
        pic.save!
        Picture.find_or_initialize_from_pic_info(pic_info).should == pic
      end
    end

    describe "#reset_stream_ratings" do
      it "should reset all pictures settings to the new ratings of the flickrstream they come from" do
        picture = Factory(:picture)
        stream = Factory(:fave_stream)
        stream.score_for(Date.today).add(1)
        stream.score_for(Date.today).add_num_of_pics(100)
        picture.synced_by(stream)
        picture.stream_rating.should == 1
        stream.score_for(Date.today).add(60)
        Picture.reset_stream_ratings
        picture.reload.stream_rating.should == 5
      end
    end

    describe "#from" do
      it "should return the list of pictures from that stream" do
        picture = Factory(:picture)
        Factory(:picture)
        stream = Factory(:fave_stream)
        picture.synced_by(stream)
        Picture.from(stream).map(&:id).should == [picture.id]
      end
    end
  end

  describe "#fave" do
    it "should add the picture to fave" do
      picture = Factory(:picture, date_upload: DateTime.new(2010, 1, 3))
      flickr.favorites.should_receive(:add).with(photo_id: picture.pic_info.id)
      picture.fave
    end

    it "should add score to the streams it comes from" do
      picture = Factory(:picture)
      picture.synced_by(Factory(:fave_stream))
      flickr.favorites.stub!(:add)
      picture.flickr_streams[0].should_receive(:add_score).with(picture.created_at, 0.3)
      picture.fave
    end

    it "should set rating to 1 when successfully added" do
      picture = Factory(:picture)
      flickr.favorites.stub!(:add)
      picture.fave
      picture.rating.should == 1
    end

    it "should only try fave it if its not faved already" do
      flickr.favorites.should_not_receive(:add)
      Factory(:picture, rating: 1).fave
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
    it "should return x number of unviewed pictures and return in a desc order" do
      picture4 = Factory(:picture, date_upload: DateTime.new(2010, 1, 4), viewed: true)
      picture3 = Factory(:picture, date_upload: DateTime.new(2010, 1, 3))
      Factory(:picture, date_upload: DateTime.new(2010, 1, 2), :viewed => true)
      picture1 = Factory(:picture, date_upload: DateTime.new(2010, 1, 1))
      Factory(:picture, date_upload: DateTime.new(2000, 1, 1))
      picture4.next_new_pictures(2).map(&:id).should == [picture3.id, picture1.id]
    end

    it "should return x number of unviewed pictures with highest rating" do
      Factory(:picture, stream_rating: 2)
      pic_with_higher_rating = Factory(:picture, stream_rating: 3)
      Factory(:picture).next_new_pictures(1)[0].id.should == pic_with_higher_rating.id
    end

    it "should return x number of unviewed pictures with latest date" do
      Factory(:picture, stream_rating: 2, date_upload: 1.month.ago)
      later_pic = Factory(:picture, stream_rating: 2, date_upload: 1.day.ago)
      Factory(:picture).next_new_pictures(1)[0].id.should == later_pic.id
    end

    it "should not include the picture itself" do
      Factory(:picture).next_new_pictures(1).should be_empty
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