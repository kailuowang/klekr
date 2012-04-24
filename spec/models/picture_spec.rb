require 'spec_helper'

describe Picture do
  before do
    @collector = FactoryGirl.create(:collector)
  end

  def create_picture(opts = {})
    FactoryGirl.create(:picture, {collector: @collector}.merge(opts))
  end

  describe "class" do

    describe "#reset_stream_ratings" do
      it "should reset all pictures settings to the new ratings of the flickrstream they come from" do
        picture = FactoryGirl.create(:picture)
        stream = FactoryGirl.create(:fave_stream)
        stream.score_for(Date.today).bump
        picture.synced_by(stream)
        picture.stream_rating.should == 2
        stream.score_for(Date.today).bump
        Picture.reset_stream_ratings
        picture.reload.stream_rating.should == 3
      end
    end

    describe "#syned_from" do
      it "should return the list of pictures from that stream" do
        picture = FactoryGirl.create(:picture)
        FactoryGirl.create(:picture)
        stream = FactoryGirl.create(:fave_stream)
        picture.synced_by(stream)
        Picture.syned_from(stream).map(&:id).should == [picture.id]
      end
    end

    describe "#collected_by" do
      it "should return pictures collected by the collector" do
        collector = FactoryGirl.create(:collector)
        pic = FactoryGirl.create(:picture, collector: collector)
        Picture.collected_by(collector).should == [pic]
      end
      it "should not return pictures collected by other collector" do
        FactoryGirl.create(:picture, collector: FactoryGirl.create(:collector))
        Picture.collected_by(FactoryGirl.create(:collector)).should be_empty
      end
    end
  end

  describe "#fave" do
    it "should add the picture to fave" do
      picture = FactoryGirl.create(:picture, date_upload: DateTime.new(2010, 1, 3))
      stub_flickr(picture, :favorites).should_receive(:add).with(photo_id: picture.pic_info.id)
      picture.fave
    end

    it "should add score to the streams it comes from" do
      picture = FactoryGirl.create(:picture)
      picture.synced_by(FactoryGirl.create(:fave_stream))
      stub_flickr(picture, :favorites).stub!(:add)
      picture.flickr_streams[0].should_receive(:add_score).with(picture.created_at)
      picture.fave
    end

    it "should set rating to 1 when successfully added" do
      picture = FactoryGirl.create(:picture)
      stub_flickr(picture, :favorites).stub!(:add)
      picture.fave
      picture.rating.should == 1
    end

    it "should only try fave it if its not faved already" do
      picture = FactoryGirl.create(:picture, rating: 1)
      stub_flickr(picture, :favorites).should_not_receive(:add)
      picture.fave
    end

    it "update ratings if already faved" do
      picture = FactoryGirl.create(:picture, rating: 1)
      stub_flickr(picture, :favorites).should_not_receive(:add)
      picture.fave(2)
      picture.rating.should == 2
    end
  end

  describe "#faved?" do
    it "should return true if rating is larger than 0" do
      FactoryGirl.create(:picture, rating: 1).should be_faved
    end
    it "should return false if rating is 0" do
      FactoryGirl.create(:picture, rating: 0).should_not be_faved
    end
  end

  describe "#synced_by" do
    it "should add the stream's ratings to the stream_rating if it not synced with the stream before" do
      picture = FactoryGirl.create(:picture)
      stream = FactoryGirl.create(:fave_stream)
      stream.stub!(:star_rating).and_return(0.2)
      picture.synced_by(stream)
      picture.stream_rating.should == 0.2
    end
  end

  describe "#get_viewed" do
    it "should update viewed as true" do
      picture = FactoryGirl.create(:picture)
      picture.get_viewed
      picture.should be_viewed
    end

    it "should update all streams's current month num_of_pics if it's viewed the first time" do
      picture = FactoryGirl.create(:picture, date_upload: 2.months.ago)
      stream = FactoryGirl.create(:fave_stream)
      picture.synced_by(stream)

      picture.get_viewed
      stream.score_for(Date.today).num_of_pics.should == 1

    end

    it "should not increas all streams's current month num_of_pics when viewed multiple times " do
      picture = FactoryGirl.create(:picture)
      stream = FactoryGirl.create(:fave_stream)
      picture.synced_by(stream)

      picture.get_viewed
      picture.get_viewed
      stream.score_for(Date.today).num_of_pics.should == 1
    end
  end


  describe "#flickr_url" do
    it "should return FlickRaw url_z when size is :medium" do
      picture = FactoryGirl.create(:picture)
      FlickRaw.should_receive(:url_z).with(picture.pic_info).and_return('http://flic.kr/a_pic_z.jpg')
      picture.flickr_url(:medium).should == 'http://flic.kr/a_pic_z.jpg?zz=1'

    end

    it "should return FlickRaw url_b when size is :large" do
      picture = FactoryGirl.create(:picture)
      FlickRaw.should_receive(:url_b).with(picture.pic_info).and_return('http://flic.kr/a_pic_z.jpg')
      picture.flickr_url(:large).should == 'http://flic.kr/a_pic_z.jpg'
    end
  end

end