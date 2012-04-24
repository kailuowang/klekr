require 'spec_helper'


describe AuthenticationsController do


  describe "GET" do
    describe "validate" do

      def create_mock_auth(user_id)
        mock(token: "a_fake_token", user: mock(nsid: user_id, username: "NNBB Alf", fullname: "Kailuo Wang"))
      end

      before do
        controller.stub!(:flickr).and_return(mock(:flickr))
      end

      it "should create a new collector with user_name, full_name and token if the user_id is not found" do
        user_id =  FactoryGirl.generate(:user_id)
        auth = create_mock_auth(user_id)

        stub_flickr(controller, :auth).should_receive(:getToken).with(frob: 'a_fake_frob').and_return(auth)
        Collector.stub(:create_default_stream)
        get "validate", :frob => 'a_fake_frob'
        collector = Collector.find_by_user_id(user_id)
        collector.auth_token.should == "a_fake_token"
        collector.user_name.should == "NNBB Alf"
        collector.full_name.should == "Kailuo Wang"
      end

      it "should create a new collector and save the collector id into session" do
        user_id =  FactoryGirl.generate(:user_id)
        auth = create_mock_auth(user_id)

        stub_flickr(controller, :auth).should_receive(:getToken).with(frob: 'a_fake_frob').and_return(auth)
        Collector.stub(:create_default_stream)

        get "validate", :frob => 'a_fake_frob'
        session[:collector_id].should == Collector.find_by_user_id(user_id).id
      end

      it "should re-use an exisiting collector with the same user_id" do
        collector = FactoryGirl.create(:collector)
        auth = create_mock_auth(collector.user_id)

        stub_flickr(controller, :auth).should_receive(:getToken).with(frob: 'a_fake_frob').and_return(auth)

        get "validate", :frob => 'a_fake_frob'
        session[:collector_id].should == collector.id

      end

    end
  end
end