require 'spec_helper'

describe FlickrStreamsController do
  describe "get my_sources" do

    it "assigns flickr streams that has collecting flag as true" do
      stream = Factory(:fave_stream, collecting: true, collector: Factory(:collector))
      controller.stub!(:current_collector).and_return stream.collector
      get "my_sources", format: :js
      response.body.should include(stream.user_id)
    end

    it "not assigns flickr streams that has collecting flag as false" do
      stream = Factory(:fave_stream, collecting: false, collector: Factory(:collector))
      controller.stub!(:current_collector).and_return stream.collector
      get "my_sources", format: :js
      response.body.should_not include(stream.user_id)

    end
  end

  describe "get sync" do
    it "should sync the fave stream" do

      fave_stream = Factory(:fave_stream)
      controller.stub!(:current_collector).and_return fave_stream.collector

      FlickrStream.stub!(:find).with(fave_stream.id).and_return(fave_stream)

      fave_stream.should_receive(:sync)
      get 'sync', id: fave_stream.id

    end
  end

  describe "put adjust_rating" do
    it "should bump rating when adjustment is up" do
      fave_stream = Factory(:fave_stream)
      controller.stub!(:current_collector).and_return fave_stream.collector

      FlickrStream.stub!(:find).with(fave_stream.id).and_return(fave_stream)
      request.env["HTTP_REFERER"] = ''
      fave_stream.should_receive(:bump_rating)
      put 'adjust_rating', id: fave_stream.id, adjustment: 'up'
    end
  end

  describe 'security' do
    it 'should forbid accessing other collector stream' do
      controller.stub!(:current_collector).and_return Factory(:collector)
      fave_stream = Factory(:fave_stream)
      lambda{ get 'show', id: fave_stream.id }.should raise_exception
    end
  end
end