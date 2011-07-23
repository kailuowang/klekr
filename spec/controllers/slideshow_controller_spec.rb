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

      data = controller.picture_data(picture)
      data[:largeUrl].should == picture.large_url
    end
  end

  describe "#new_pictures" do
    it "return interesting pictures after the target picture" do
      collector = Factory(:collector)
      controller.stub(:current_collector).and_return(collector)

      new_pic = Factory(:picture)

      Picture.should_receive(:new_pictures_by).with(collector, 7, [1, 2, 3]).and_return([new_pic])

      post "new_pictures", format: :js, exclude_ids: [1,2,3], num: 7

      response.body.should include new_pic.large_url

    end
  end
end