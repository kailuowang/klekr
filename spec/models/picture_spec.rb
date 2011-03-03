require 'spec_helper'

describe Picture do
  describe "#create_from_pic_info" do
    it "should be able to create from flickr pic info" do
      pic_info = Factory.next(:pic_info)
      pic_info.stub!(:dateupload).and_return 1297935005
      FlickRaw.should_receive(:url_photopage).with(pic_info).and_return('http://flickr/photo/pic1')
      Picture.create_from_pic_info(pic_info)
      picture = Picture.all.first
      picture.url.should == 'http://flickr/photo/pic1'
      picture.date_upload.should == Time.at(1297935005).to_datetime
      picture.pic_info.secret.should == pic_info.secret
    end

    it "should not create duplicate picture" do
      pic_info = Factory.next(:pic_info)
      Picture.create_from_pic_info(pic_info)
      Picture.create_from_pic_info(pic_info)
      Picture.count.should == 1
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

  describe "#previous_pictures" do
    it "should return x number of previous pictures in the chain" do
      picture3 = Factory(:picture, date_upload: DateTime.new(2010, 1, 3))
      picture2 = Factory(:picture, date_upload: DateTime.new(2010, 1, 2))
      picture1 = Factory(:picture, date_upload: DateTime.new(2010, 1, 1))
      Factory(:picture, date_upload: DateTime.new(2000, 1, 1))
      picture3.previous_pictures(2).should == [picture2, picture1]
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