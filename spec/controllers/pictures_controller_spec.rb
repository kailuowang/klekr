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
      Factory( :picture, date_upload:  3.hour.ago , :viewed => true)
      pic2 = Factory( :picture, date_upload:  2.hour.ago )
      pic = Factory( :picture, date_upload: 1.hour.ago, :viewed => true )
      get 'show', :id => pic.id
      get 'slide_show'

      response.should redirect_to pic2
    end

  end

  describe "GET show" do
    it "should not change viewed? flag when showing the picture" do
      Factory( :picture, date_upload:  2.hour.ago )
      pic = Factory( :picture, date_upload: 1.hour.ago )
      get 'show', :id => pic.id
      pic.reload
      pic.should_not be_viewed
    end
  end

  describe "GET next" do
    it "should redirect to the next new picture when there is one" do
      pic = Factory( :picture, date_upload: 1.hour.ago )
      pic2 = Factory( :picture, date_upload:  2.hour.ago )
      get 'next', :id => pic.id

      response.should redirect_to pic2
    end

    it "should set the pic next from as viewed" do
      pic = Factory( :picture, date_upload: 1.hour.ago )

      get 'next', :id => pic.id
      pic.reload
      pic.should be_viewed
    end

    it "should redirect to the slide_show picture when there is no next one" do
      pic = Factory( :picture, date_upload: 1.hour.ago )
      get 'next', :id => pic.id

      response.should redirect_to flickr_streams_path
    end

    it "should redirect to the hidden treasure if the hidden_treaure is in parameter" do
      Factory( :picture)
      pic2 = Factory( :picture)
      pic = Factory( :picture)

      Picture.stub!(:find).with(pic.id).and_return(pic)
      Picture.stub!(:find).with(pic2.id).and_return(pic2)
      pic.stub!(:guess_hidden_treasure).and_return(pic2)
      get 'next', :id => pic.id, :hidden_treasure => true

      response.should redirect_to picture_path(id: pic2.id, hidden_treasure: true)
    end


  end
end
