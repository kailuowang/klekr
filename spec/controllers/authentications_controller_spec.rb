require 'spec_helper'


describe AuthenticationsController do

  describe "GET" do


    describe "validate" do

      def create_mock_auth(user_id)
        mock(token: "a_fake_token", user: mock(nsid: user_id, username: "NNBB Alf", fullname: "Kailuo Wang"))
      end

      it "should create a new collector with user_name, full_name and token if the user_id is not found" do
        user_id = Factory.next(:user_id)
        auth = create_mock_auth(user_id)

        flickr.auth.should_receive(:getToken).with(frob: 'a_fake_frob').and_return(auth)

        get "validate", :frob => 'a_fake_frob'
        collector = Collector.find_by_user_id(user_id)
        collector.auth_token.should == "a_fake_token"
        collector.user_name.should == "NNBB Alf"
        collector.full_name.should == "Kailuo Wang"
      end

      it "should create a new collector and save the collector id into session" do
        user_id = Factory.next(:user_id)
        auth = create_mock_auth(user_id)

        flickr.auth.should_receive(:getToken).with(frob: 'a_fake_frob').and_return(auth)

        get "validate", :frob => 'a_fake_frob'
        session[:collector_id].should == Collector.find_by_user_id(user_id).id
      end

      it "should re-use an exisiting collector with the same user_id" do
        collector = Factory(:collector)
        auth = create_mock_auth(collector.user_id)

        flickr.auth.should_receive(:getToken).with(frob: 'a_fake_frob').and_return(auth)

        get "validate", :frob => 'a_fake_frob'
        session[:collector_id].should == collector.id

      end

      it "should make sure the current collector get stored in Thread.current" do
        collector = Factory(:collector)
        flickr.auth.stub!(:getToken).and_return(create_mock_auth(collector.user_id))

        get "validate", :frob => 'a_fake_frob'
        Thread.current[:current_collector].should == collector

      end

    end
  end
end