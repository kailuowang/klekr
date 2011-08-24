require 'spec_helper'

describe Collectr::PictureRepo do
  before do
    @collector = Factory(:collector)
    @repo = Collectr::PictureRepo.new(@collector)
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
        pic = Picture.find_or_initialize_from_pic_info(@pic_info, @collector)
        pic.save
        @repo.find(pic.flickr_id).should == pic
      end

      it "does not find existing picture with different collector" do
        pic = Picture.find_or_initialize_from_pic_info(@pic_info, Factory(:collector))
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