require 'spec_helper'

describe Collectr::PictureRepo do
  before do
    @collector = Factory(:collector)
    @repo = Collectr::PictureRepo.new(@collector)
  end

  describe "#find_or_initialize_from_pic_info" do
    it "should be able to create from flickr pic info" do
      pic_info = Factory.next(:pic_info)
      FlickRaw.should_receive(:url_photopage).with(pic_info).and_return('http://flickr/photo/pic1')
      picture = @repo.find_or_initialize_from_pic_info(pic_info)
      picture.url.should == 'http://flickr/photo/pic1'
      picture.date_upload.should == Time.at(pic_info.dateupload.to_i).to_datetime
      picture.owner_name.should == pic_info.ownername
      picture.pic_info.secret.should == pic_info.secret
    end

    it "should not create duplicate picture for the same collector" do
      pic_info = Factory.next(:pic_info)
      pic = @repo.find_or_initialize_from_pic_info(pic_info)
      pic.save!
      @repo.find_or_initialize_from_pic_info(pic_info).should == pic
    end

    it "should create duplicate picture for different collectors" do
      pic_info = Factory.next(:pic_info)
      pic = Collectr::PictureRepo.new(Factory(:collector)).find_or_initialize_from_pic_info(pic_info)
      pic.save!
      @repo.find_or_initialize_from_pic_info(pic_info).should_not == pic
    end
  end

  describe "#find" do
    it "finds picture by db id" do
      pic = Factory(:picture, collector: @collector)
      @repo.find(pic.id).should == pic
    end

    context 'finding by flickr_id' do
      before do
        @pic_info = Factory.next(:pic_info)
        stub_flickr(@repo, :photos).
          should_receive(:getInfo).
          with(photo_id: @pic_info.id, secret: @pic_info.secret).
          and_return(@pic_info)
      end

      it "find existing picture with the same collector in DB" do
        pic = @repo.build(@pic_info)
        pic.save
        @repo.find(pic.flickr_id).should == pic
      end

      it "does not find existing picture with different collector" do
        pic = Collectr::PictureRepo.new(Factory(:collector)).build(@pic_info)
        pic.save
        @repo.find(pic.flickr_id).should_not == pic
      end

      it "creates a picture for the collector if not find in db" do
        pic = @repo.find(Picture.flickr_id(@pic_info))
        pic.collector.should == @collector
        pic.title.should == @pic_info.title
      end
    end
  end

end