require 'spec_helper'

describe CookieSettingsController do

  describe "put 'update'" do
    it "should be successful" do
      @request.env['HTTP_REFERER'] = 'http://localhost:3000/pictures'
      put :update, id: :dummy_id, picture_show_size: 'large'
      cookies['picture_show_size'].should == 'large'
      response.should redirect_to(:back)
    end
  end

end
