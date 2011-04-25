require 'spec_helper'

describe UsersController do

  describe "GET 'show'" do
    before do
      controller.stub!(:get_pictures_from).and_return([])
    end

    it "should assign the fave_stream by the current collector" do
      user_info = Factory.next(:user_info)
      user_id = user_info.nsid

      stub_flickr(controller, :people).stub!(:getInfo).and_return(user_info)

      collector = Factory(:collector)
      stream = Factory(:fave_stream, user_id: user_id, collector: collector )
      controller.stub!(:current_collector).and_return(collector)
      get 'show', id: 'a_user_id'
      assigns(:fave_stream).should == stream
    end

    it "should not assign the fave_stream not by the current collector" do
      user_info = Factory.next(:user_info)
      user_id = user_info.nsid

      stub_flickr(controller, :people).stub!(:getInfo).and_return(user_info)

      collector = Factory(:collector)
      Factory(:fave_stream, user_id: user_id, collector: Factory(:collector) )
      controller.stub!(:current_collector).and_return(collector)
      get 'show', id: 'a_user_id'
      assigns(:fave_stream).should be_nil
    end
  end

  describe "GET 'subscribe'" do
    it "should set the current collector as the stream's collector" do
      user_info = Factory.next(:user_info)
      stub_flickr(FlickrStream, :people).stub!(:getInfo).and_return(user_info)
      collector = Factory(:collector)
      controller.stub!(:current_collector).and_return(collector)
      get 'subscribe', id: 'a_user_id', type: 'FaveStream'
      collector.flickr_streams.size.should == 1
    end
  end

  describe "GET 'search'" do
    it "should be successful"
  end

end
