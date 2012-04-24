require 'spec_helper'

describe SlideshowController do

  describe "#new_pictures" do
    it "return interesting pictures after the target picture" do
      collector = FactoryGirl.create(:collector)
      controller.stub(:current_collector).and_return(collector)

      new_pic = FactoryGirl.create(:picture)
      repo = mock(:repo)

      Collectr::PictureRepo.should_receive(:new).with(collector).and_return(repo)

      repo.should_receive(:new_pictures).with(limit: '7', offset: '10').and_return([new_pic])

      get "new_pictures", format: :json, limit: 7, offset: 10

      response.body.should include new_pic.large_url

    end
  end
end