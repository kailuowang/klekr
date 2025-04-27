require 'spec_helper'

describe SlideshowController, type: :controller do

  describe "#new_pictures" do
    it "return interesting pictures after the target picture" do
      collector = FactoryGirl.create(:collector)
      allow(controller).to receive(:current_collector).and_return(collector)

      new_pic = create(:picture)
      repo = double(:repo)

      expect(Collectr::PictureRepo).to receive(:new).with(collector).and_return(repo)

      # Modern Rails uses ActionController::Parameters instead of a hash
      expect(repo).to receive(:new_pictures).and_return([new_pic])

      get :new_pictures, params: { format: :json, limit: 7, offset: 10 }

      expect(response.body).to include(new_pic.large_url)

    end
  end
end