require 'spec_helper'

describe SlideshowController do
  describe "#picture_data" do
    it "include the large url in the data" do
      picture = Factory(:picture)

      controller.picture_data(picture)[:large_url].should == picture.large_url
    end
  end


#describe "GET slide_show" do
#    it "should redirect to show the latest picture" do
#      collector = Factory(:collector)
#      Factory( :picture, date_upload:  2.hour.ago, collector: collector)
#      pic = Factory( :picture, date_upload: 1.hour.ago, collector: collector)
#      controller.stub!(:current_collector).and_return(collector)
#      get 'slide_show'
#      response.should redirect_to pic
#    end
#    it "should redirect to show the picture collected by the current collector" do
#      collector = Factory(:collector)
#      Factory( :picture, date_upload:  1.hour.ago)
#      pic = Factory( :picture, date_upload: 2.hour.ago, collector: collector)
#      controller.stub!(:current_collector).and_return(collector)
#      get 'slide_show'
#      response.should redirect_to pic
#    end
#
#    it "should redirect to show the latest picture that has not been viewed yet" do
#      collector = Factory(:collector)
#
#      Factory( :picture, date_upload:  3.hour.ago , :viewed => true, collector: collector)
#      pic2 = Factory( :picture, date_upload:  2.hour.ago, collector: collector )
#      pic = Factory( :picture, date_upload: 1.hour.ago, :viewed => true, collector: collector )
#      get 'show', id: pic.id
#      get 'slide_show'
#
#      response.should redirect_to pic2
#    end
#
#  end

end