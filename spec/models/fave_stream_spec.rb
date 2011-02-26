require 'spec_helper'
require 'flickraw'

describe FaveStream do
  describe "#sync" do

    before do
      @flickr_favorites = mock
      flickr.stub(:favorites).and_return(@flickr_favorites)
    end

    it "should sync to get pictures from flickr" do
      a_pic_info = mock
      another_pic_info = mock
      fav_stream = FaveStream.new(:user_id => 'a_user_id')
      @flickr_favorites.should_receive(:getList).
              with(hash_including(user_id: 'a_user_id')).
              and_return([a_pic_info, another_pic_info])

      Picture.should_receive(:create_from_pic_info).with(a_pic_info)
      Picture.should_receive(:create_from_pic_info).with(another_pic_info)
      fav_stream.sync
    end

    it "should sync with date upload for pictures" do
      fav_stream = FaveStream.new(:user_id => 'a_user_id')
      @flickr_favorites.should_receive(:getList).
              with(hash_including(extra: 'date_upload')).
              and_return([])

      fav_stream.sync
    end

  end
end