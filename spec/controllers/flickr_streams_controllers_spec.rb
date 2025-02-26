require 'spec_helper'

describe FlickrStreamsController, type: :controller do
  describe "get my_sources" do

    it "assigns flickr streams that has collecting flag as true" do
      stream = create(:fave_stream, collecting: true, collector: create(:collector))
      allow(controller).to receive(:current_collector).and_return(stream.collector)
      get :my_sources, params: { format: :json }
      expect(response.body).to include(stream.user_id)
    end

    it "not assigns flickr streams that has collecting flag as false" do
      stream = create(:fave_stream, collecting: false, collector: create(:collector))
      allow(controller).to receive(:current_collector).and_return(stream.collector)
      get :my_sources, params: { format: :json }
      expect(response.body).not_to include(stream.user_id)

    end
  end

  describe "get sync" do
    it "should sync the fave stream" do

      fave_stream = create(:fave_stream)
      allow(controller).to receive(:current_collector).and_return(fave_stream.collector)

      allow(FlickrStream).to receive(:find).with(fave_stream.id).and_return(fave_stream)

      expect(fave_stream).to receive(:sync)
      get :sync, params: { id: fave_stream.id, format: :json }

    end
  end

  describe "put adjust_rating" do
    it "should bump rating when adjustment is up" do
      fave_stream = create(:fave_stream)
      allow(controller).to receive(:current_collector).and_return(fave_stream.collector)

      allow(FlickrStream).to receive(:find).with(fave_stream.id).and_return(fave_stream)
      request.env["HTTP_REFERER"] = ''
      expect(fave_stream).to receive(:bump_rating)
      put :adjust_rating, params: { id: fave_stream.id, adjustment: 'up', format: :json }
    end
  end

  describe 'security' do
    it 'should forbid accessing other collector stream' do
      allow(controller).to receive(:current_collector).and_return(create(:collector))
      fave_stream = create(:fave_stream)
      expect { put :subscribe, params: { id: fave_stream.id } }.to raise_error
    end
  end
end