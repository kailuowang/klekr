require 'spec_helper'

describe FlickrStreamsController do
  describe "get sync" do
    it "should sync the fave stream" do

      fave_stream = Factory(:fave_stream)

      FlickrStream.stub!(:find).with(fave_stream.id).and_return(fave_stream)

      fave_stream.should_receive(:sync)
      request.env["HTTP_REFERER"] = 'http://google.com'
      get 'sync', id: fave_stream.id
      response.should redirect_to(:back)

    end
  end

  describe "post create" do
    it "should create a FlickrStream" do
      params = { 'user_id' => 'a_user_id', 'type' => 'fave' }
      FlickrStream.should_receive(:build).with(params).and_return(Factory(:fave_stream))
      post 'create', flickr_stream: params
      response.should redirect_to(action: 'index')
    end
  end
end