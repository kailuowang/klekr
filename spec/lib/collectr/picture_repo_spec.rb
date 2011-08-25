require 'spec_helper'

describe Collectr::PictureRepo do
  before do
    @collector = Factory(:collector)
    @repo = Collectr::PictureRepo.new(@collector)
  end

  def create_picture(opts = {})
    Factory(:picture, {collector: @collector}.merge(opts))
  end

  describe ".new_pictures" do
    it "return  of unviewed pictures and return in a desc order" do
      create_picture(date_upload: DateTime.new(2010, 1, 4), viewed: true)
      picture3 = create_picture(date_upload: DateTime.new(2010, 1, 3))
      create_picture(date_upload: DateTime.new(2010, 1, 2), :viewed => true)
      picture1 = create_picture(date_upload: DateTime.new(2010, 1, 1))
      create_picture(date_upload: DateTime.new(2000, 1, 1))
      @repo.new_pictures(page: 1, per_page: 2).should == [picture3, picture1]
    end

    it "return unviewed pictures with highest rating" do
      create_picture(stream_rating: 2)
      pic_with_higher_rating = create_picture(stream_rating: 3)
      @repo.new_pictures.first.should == pic_with_higher_rating
    end

    it "return unviewed pictures with latest date" do
      create_picture(date_upload: 1.month.ago)
      later_pic = create_picture(date_upload: 2.days.ago)
      @repo.new_pictures.first.should == later_pic
    end

    it "return pictures by the collector" do
      pic = create_picture(:collector => @collector)
      @repo.new_pictures.first.should == pic
    end

    it "does not return pictures by a different collector" do
      create_picture(:collector => Factory(:collector))
      @repo.new_pictures.should be_empty
    end

    it "include the pictures of not in the list of exclude_ids if given" do
      pic_to_exclude = create_picture
      pic_to_include = create_picture
      @repo.new_pictures(excluded_ids: [pic_to_exclude.id]).should include(pic_to_include)
    end

    it "exclude the pictures of the exclude_ids if given" do
      pic1 = create_picture
      pic2 = create_picture
      @repo.new_pictures(excluded_ids: [pic1.id, pic2.id]).should_not include(pic1, pic2)
    end

    it "does not include pictures that are collected" do
      pic1 = create_picture(collected: false)
      @repo.new_pictures.should_not include(pic1)
    end

    it "accept string as page and per_page" do
      create_picture
      @repo.new_pictures(page: '1', per_page: '3').should be_present
    end


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