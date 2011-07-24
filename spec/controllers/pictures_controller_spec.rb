require 'spec_helper'

describe PicturesController do

  describe "#current" do
    it "return the json data for the most_interesting_picture of the collector" do
      collector = Factory(:collector)
      picture = Factory(:picture)
      controller.stub(:current_collector).and_return(collector)
      Picture.should_receive(:most_interesting_for).with(collector).and_return(picture)
      get "current", format: :js
      response.body.should include picture.large_url

    end
  end


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
