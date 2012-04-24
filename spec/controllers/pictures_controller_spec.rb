require 'spec_helper'

describe PicturesController do
  before do
    @collector = FactoryGirl.create(:collector)
  end

  def stub_current(collector = @collector)
    controller.stub(:current_collector).and_return(collector)
  end

  def should_raise_exception_for_pictures_from_other_collector(method, action, params)
    stub_current
    lambda{ send(method, action, params.reverse_merge(format: :json)) }.should raise_exception
  end

  def create_picture
    stub_current
    FactoryGirl.create(:picture, collector: @collector)
  end

  describe "PUT fave" do

    it "should mark the picture as faved" do
      pic = create_picture
      Picture.stub!(:find).with(pic.id.to_s).and_return(pic)
      pic.should_receive(:fave).with(1)
      put 'fave', format: :json, id: pic.id
    end

    it "faves picture that is not collected yet (in db)" do
      pic = create_picture
      Picture.stub!(:find).with(pic.id.to_s).and_return(pic)
      pic.should_receive(:fave)
      put 'fave', format: :json, id: pic.id
    end

    it "should mark the picture as viewed" do
      pic = create_picture
      repo = Collectr::PictureRepo.new(nil)
      Collectr::PictureRepo.stub(:new).and_return(repo)
      repo.stub(:find_by_flickr_id).with('fakeflickr_photoid').and_return(pic)
      pic.should_receive(:fave)
      put 'fave', format: :json, id: 'fakeflickr_photoid'
    end

    it "should not change pic from other collector" do
      stub_current
      others_pic = FactoryGirl.create(:picture, collector: FactoryGirl.create(:collector))
      FlickRaw::Flickr.stub_chain(:new, :favorites, :add)
      put 'fave', format: :json, id: others_pic.id
      others_pic.reload
      others_pic.should_not be_faved
      @collector.pictures.faved.count.should == 1
    end

  end

  describe "POST all_viewed" do
    it "mark all passed picture ids as viewed" do
      stub_current
      picture_ids  = 3.pictures(collector: @collector).map(&:id)
      post 'all_viewed', ids: picture_ids
      Picture.unviewed.count.should == 0
    end

    it "should forbid from changing pics from other collector" do
      picture_ids  = 3.pictures.map(&:id)
      should_raise_exception_for_pictures_from_other_collector(:post, 'all_viewed', ids: picture_ids)
    end
  end

end
