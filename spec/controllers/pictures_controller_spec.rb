require 'spec_helper'

describe PicturesController do
  describe "GET slide_show" do
    it "should redirect to show the latest picture" do
      Factory( :picture, date_upload:  2.hour.ago )
      pic = Factory( :picture, date_upload: 1.hour.ago )
      get 'slide_show'
      response.should redirect_to pic
    end

    it "should redirect to show the latest picture that has not been viewed yet" do
      pic3 = Factory( :picture, date_upload:  3.hour.ago )
      pic2 = Factory( :picture, date_upload:  2.hour.ago )
      pic = Factory( :picture, date_upload: 1.hour.ago )
      get 'show', :id => pic.id
      get 'slide_show'

      response.should redirect_to pic2
    end
  end

  describe "GET show" do
    it "should set the picture's read shown as true" do
      Factory( :picture, date_upload:  2.hour.ago )
      pic = Factory( :picture, date_upload: 1.hour.ago )
      get 'show', :id => pic.id
      pic.reload
      pic.should be_viewed
    end
  end
end
