require 'spec_helper'

describe Picture do
  describe "class" do
    describe "#create_from_pic_info" do
      it "should be able to create from flickr pic info" do
        pic_info = Factory.next(:pic_info)
        pic_info.stub!(:dateupload).and_return 1297935005
        FlickRaw.should_receive(:url_photopage).with(pic_info).and_return('http://flickr/photo/pic1')
        picture = Picture.create_from_pic_info(pic_info)
        picture.url.should == 'http://flickr/photo/pic1'
        picture.date_upload.should == Time.at(1297935005).to_datetime
        picture.owner_name.should == pic_info.ownername
        picture.pic_info.secret.should == pic_info.secret

      end

      it "should not create duplicate picture" do
        pic_info = Factory.next(:pic_info)
        pic = Picture.create_from_pic_info(pic_info)
        pic.save!
        Picture.create_from_pic_info(pic_info).should == pic
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
      picture.flickr_streams[0].should_receive(:add_score).with(picture.created_at)
      picture.fave
    end

  end

  describe "#previous" do
    it "should get the picture in the database that has the closest earlier date_upload" do
      picture1 = Factory(:picture, date_upload: DateTime.new(2010, 1, 3))
      Factory(:picture, date_upload: DateTime.new(2010, 1, 1))
      picture2 = Factory(:picture, date_upload: DateTime.new(2010, 1, 2))
      picture1.previous.should == picture2
    end
  end

  describe "#next_new_pictures" do
    it "should return x number of unviewed pictures and return in a desc order" do
      picture4 = Factory(:picture, date_upload: DateTime.new(2010, 1, 4))
      picture3 = Factory(:picture, date_upload: DateTime.new(2010, 1, 3))
      Factory(:picture, date_upload: DateTime.new(2010, 1, 2), :viewed => true)
      picture1 = Factory(:picture, date_upload: DateTime.new(2010, 1, 1))
      Factory(:picture, date_upload: DateTime.new(2000, 1, 1))
      picture4.next_new_pictures(2).should == [picture3, picture1]
    end
  end

  describe "#next" do
    it "should get the picture in the database that has the closest later date_upload" do
      picture1 = Factory(:picture, date_upload: DateTime.new(2010, 1, 1))
      Factory(:picture, date_upload: DateTime.new(2010, 1, 3))
      picture2 = Factory(:picture, date_upload: DateTime.new(2010, 1, 2))
      picture1.next.should == picture2
    end
  end

  describe "#flickr_url" do
    it "should return FlickRaw url_z when size is :medium" do
      picture = Factory(:picture)
      FlickRaw.should_receive(:url_z).with(picture.pic_info).and_return('http://flic.kr/a_pic_z.jpg')
      picture.flickr_url(:medium).should == 'http://flic.kr/a_pic_z.jpg'

    end

    it "should return FlickRaw url_b when size is :large" do
      picture = Factory(:picture)
      FlickRaw.should_receive(:url_b).with(picture.pic_info).and_return('http://flic.kr/a_pic_z.jpg')
      picture.flickr_url(:large).should == 'http://flic.kr/a_pic_z.jpg'

    end
  end



end