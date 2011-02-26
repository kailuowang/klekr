require 'spec_helper'
require 'flickraw'

describe FaveStream do
  describe "#sync" do
    it "should sync to get pictures from flickr" do
      fav_stream = FaveStream.new(:user_id => 'a_user_id')
      flickr_favorites = mock
      flickr.stub(:favorites).and_return(flickr_favorites)
      flickr_favorites.should_receive(:getList).with(:user_id => 'a_user_id').and_return(
          [mock(:secret => 'pic1'), mock(:secret => 'pic2')]
      )
      fav_stream.sync
      Picture.all.map(&:secret).sort.should == ['pic1', 'pic2']
    end

  end
end