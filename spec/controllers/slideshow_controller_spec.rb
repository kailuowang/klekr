require 'spec_helper'

describe SlideshowController do

  describe "#new_pictures" do
    it "return interesting pictures after the target picture" do
      collector = Factory(:collector)
      controller.stub(:current_collector).and_return(collector)

      new_pic = Factory(:picture)

      Picture.should_receive(:new_pictures_by).with(collector, *[1, 2, 3]).and_return(mock(paginate: [new_pic]))


      post "new_pictures", format: :js, exclude_ids: [1,2,3], num: 7

      response.body.should include new_pic.large_url

    end
  end
end