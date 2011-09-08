require 'spec_helper'

describe PicturesController do


  describe "PUT fave" do

    it "should mark the picture as faved" do
      pic = Factory(:picture)
      Picture.stub!(:find).with(pic.id.to_s).and_return(pic)
      pic.should_receive(:fave)
      put 'fave', format: :json, id: pic.id
    end

    it "faves picture that is not collected yet (in db)" do
      pic = Factory(:picture)
      Picture.stub!(:find).with(pic.id.to_s).and_return(pic)
      pic.should_receive(:fave)
      put 'fave', format: :json, id: pic.id
    end

    it "should mark the picture as viewed" do
      pic = Factory(:picture)
      repo = Collectr::PictureRepo.new(nil)
      Collectr::PictureRepo.stub(:new).and_return(repo)
      repo.stub(:find_by_flickr_id).with('fakeflickr_photoid').and_return(pic)
      pic.should_receive(:fave)
      put 'fave', format: :json, id: 'fakeflickr_photoid'
    end
  end

  describe "POST all_viewed" do
    it "mark all passed picture ids as viewed" do
      picture_ids  = 3.pictures.map(&:id)
      post 'all_viewed', ids: picture_ids
      Picture.unviewed.count.should == 0

    end
  end

end
