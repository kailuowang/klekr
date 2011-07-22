require 'spec_helper'

describe SlideshowController do

  describe "#current" do
    it "return the json data for the most_interesting_picture of the collector" do
      collector = Factory(:collector)
      picture = Factory(:picture)
      controller.stub(:current_collector).and_return(collector)
      Picture.should_receive(:most_interesting_for).with(collector).and_return(picture)
      get "current", format: :js
      response.body.should include picture.large_url

    end
  end

  describe "#picture_data" do
    it "include the large url in the data" do
      picture = Factory(:picture)

      controller.picture_data(picture)[:large_url].should == picture.large_url
    end
  end

  describe "#pictures_after" do
    it "return interesting pictures after the target picture" do
      target_pic = Factory(:picture)
      Picture.should_receive(:find).with(target_pic.id).and_return(target_pic)

      new_pic = Factory(:picture)
      target_pic.should_receive(:next_new_pictures).with(7).and_return([new_pic])

      get "pictures_after", format: :js, target_picture: target_pic.id, num: 7

      response.body.should include new_pic.large_url

    end
  end
end