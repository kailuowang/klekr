require 'spec_helper'


describe AuthenticationsController, type: :controller do


  describe "GET" do
    describe "validate" do

      def create_mock_auth(user_id)
        double(token: "a_fake_token", user: double(nsid: user_id, username: "NNBB Alf", fullname: "Kailuo Wang"))
      end

      before do
        allow(controller).to receive(:flickr).and_return(double(:flickr))
      end

      it "should create a new collector with user_name, full_name and token if the user_id is not found" do
        user_id = "test-user-#{Time.now.to_i}"
        auth = create_mock_auth(user_id)

        mockAuth = stub_flickr(controller, :auth)
        expect(mockAuth).to receive(:getToken).with(frob: 'a_fake_frob').and_return(auth)
        allow(Collector).to receive(:create_default_stream)
        get :validate, params: { frob: 'a_fake_frob' }
        collector = Collector.find_by_user_id(user_id)
        expect(collector.auth_token).to eq("a_fake_token")
        expect(collector.user_name).to eq("NNBB Alf")
        expect(collector.full_name).to eq("Kailuo Wang")
      end

      it "should create a new collector and save the collector id into session" do
        user_id = "test-user-#{Time.now.to_i}"
        auth = create_mock_auth(user_id)

        mockAuth = stub_flickr(controller, :auth)
        expect(mockAuth).to receive(:getToken).with(frob: 'a_fake_frob').and_return(auth)
        allow(Collector).to receive(:create_default_stream)

        get :validate, params: { frob: 'a_fake_frob' }
        expect(session[:collector_id]).to eq(Collector.find_by_user_id(user_id).id)
      end

      it "should re-use an exisiting collector with the same user_id" do
        collector = create(:collector)
        auth = create_mock_auth(collector.user_id)

        mockAuth = stub_flickr(controller, :auth)
        expect(mockAuth).to receive(:getToken).with(frob: 'a_fake_frob').and_return(auth)

        get :validate, params: { frob: 'a_fake_frob' }
        expect(session[:collector_id]).to eq(collector.id)

      end

    end
  end
end