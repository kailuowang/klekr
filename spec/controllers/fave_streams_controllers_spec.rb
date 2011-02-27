require 'spec_helper'

describe FaveStreamsController do
  describe "get sync" do
    it "should sync the fave stream" do

      fave_stream = mock_model(FaveStream)

      FaveStream.stub!(:find).with(fave_stream.id).and_return(fave_stream)

      fave_stream.should_receive(:sync)
      get 'sync', id: fave_stream.id
      response.should redirect_to(action: 'index')

    end
  end
end