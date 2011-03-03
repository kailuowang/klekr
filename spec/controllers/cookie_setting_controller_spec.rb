require 'spec_helper'

describe CookieSettingsController do

  describe "put 'update'" do
    it "should be successful" do
      @request.env['HTTP_REFERER'] = 'http://localhost:3000/pictures'
      put :update, id: :dummy_id, window_size: 'large'
      cookies['window_size'].should == 'large'
      response.should redirect_to(:back)
    end
  end

end
