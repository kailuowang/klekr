require 'spec_helper'

describe UsersController do

  describe "GET 'show'" do
    it "should be successful"
  end

  describe "GET 'subscribe'" do
    it "should set the current collector as the stream's collector" do
      user_info = Factory.next(:user_info)
      flickr.people.stub!(:getInfo).and_return(user_info)
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
