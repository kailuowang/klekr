require 'spec_helper'

describe FlickrStreamsController do
  describe "get index" do


    it "assigns flickr streams that has collecting flag as true" do
      stream = Factory(:fave_stream, collecting: true, collector: Factory(:collector))
      controller.stub!(:current_collector).and_return stream.collector
      get "index", format: :js
      response.body.should include(stream.user_id)
    end

    it "not assigns flickr streams that has collecting flag as false" do
      stream = Factory(:fave_stream, collecting: false, collector: Factory(:collector))
      controller.stub!(:current_collector).and_return stream.collector
      get "index", format: :js
      response.body.should_not include(stream.user_id)

    end
  end

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

  describe "put adjust_rating" do
    it "should bump rating when adjustment is up" do
      fave_stream = Factory(:fave_stream)
      FlickrStream.stub!(:find).with(fave_stream.id).and_return(fave_stream)
      request.env["HTTP_REFERER"] = ''
      fave_stream.should_receive(:bump_rating)
      put 'adjust_rating', id: fave_stream.id, adjustment: 'up'
    end
  end
end