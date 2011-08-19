require 'spec_helper'

describe PicturesController do


  describe "PUT fave" do

    it "should mark the picture as faved" do
      pic = Factory(:picture)
      Picture.stub!(:find).with(pic.id).and_return(pic)
      pic.should_receive(:fave)
      put 'fave', format: :json, id: pic.id
    end

    it "should mark the picture as viewed" do
      pic = Factory(:picture)
      Picture.stub!(:find).with(pic.id).and_return(pic)
      pic.should_receive(:get_viewed)
      pic.stub!(:fave)
      put 'fave', format: :json, id: pic.id
    end
  end


end
