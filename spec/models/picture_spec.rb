require 'spec_helper'

describe Picture do
  describe "#create_from_pic_info" do
    it "should be able to create from flickr pic info" do
      pic_info = mock(secret: 'pic1', title: 'title1', dateupload: DateTime.new(2001,2,1))
      FlickRaw.should_receive(:url_photopage).with(pic_info).and_return('http://flickr/photo/pic1')
      FlickRaw.should_receive(:url_b).with(pic_info).and_return('http://flickr/photo/pic1_b.jpg')
      Picture.create_from_pic_info(pic_info)
      picture = Picture.all.first
      picture.secret.should == 'pic1'
      picture.title.should == 'title1'
      picture.ref_url.should == 'http://flickr/photo/pic1'
      picture.url.should == 'http://flickr/photo/pic1_b.jpg'
      picture.date_upload.should == DateTime.new(2001,2,1)
    end

    it "should not create duplicate picture" do
      pic_info = mock(secret: 'pic1', title: 'title1', dateupload: DateTime.new(2001,2,1))
      FlickRaw.stub!(:url_photopage)
      FlickRaw.stub!(:url_b)
      Picture.create_from_pic_info(pic_info)
      Picture.create_from_pic_info(pic_info)
      Picture.count.should == 1

    end

  end
end