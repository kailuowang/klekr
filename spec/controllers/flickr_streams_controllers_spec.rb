require 'spec_helper'

describe FlickrStreamsController do
  describe "get sync" do
    it "should sync the fave stream" do

      fave_stream = Factory(:fave_stream)

      FlickrStream.stub!(:find).with(fave_stream.id).and_return(fave_stream)

      fave_stream.should_receive(:sync)
      get 'sync', id: fave_stream.id
      response.should redirect_to(action: 'index')

    end
  end

  describe "post create" do
    it "should create a FlickrStream" do
      post 'create', flickr_stream: { user_id: 'a_user_id', type: 'upload' }
      UploadStream.first.user_id.should == 'a_user_id'
    end
  end
end