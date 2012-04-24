require 'spec_helper'

describe MonthlyScore do
  describe "#time_weight" do
    it "should be 1 if its within 2 months ago" do
      MonthlyScore.new(month: 2.month.ago.month, year: 2.month.ago.year).time_weight.should == 1
      MonthlyScore.new(month: 1.month.ago.month, year: 1.month.ago.year).time_weight.should == 1
    end

    it "should be divided by log of months from now" do
      four_month_ago = Time.now.months_ago(4)
      MonthlyScore.new(month: 4.month.ago.month, year: 4.month.ago.year).time_weight.should == 0.5
      MonthlyScore.new(month: 16.month.ago.month, year: 16.month.ago.year).time_weight.should == 0.25
    end

    it "should be partial for the current month" do
      Date.stub!(:today).and_return(Date.new(2011, 4, 15))
      MonthlyScore.new(month: Date.today.month, year: Date.today.year).time_weight.should == 0.5
    end
  end

  describe "#weighted_rating" do
    it 'should return 0 if there is no pics for that month' do
      MonthlyScore.new(month: 4, year: 2011).weighted_rating.should == 0
    end
  end

  describe "#bump" do
    it "should increase rating when there is num of pics" do
      ms = FactoryGirl.create(:monthly_score)
      ms.add_num_of_pics_viewed(10)
      ms.bump
      ms.rating.should > 0
    end

    it "should increase rating when there no num of pics" do
      ms = FactoryGirl.create(:monthly_score)
      ms.bump
      ms.rating.should > 0
    end
  end


  describe "#trash" do
    it "should decrease rating when there is num of pics" do
      ms = FactoryGirl.create(:monthly_score)
      ms.add_num_of_pics_viewed(10)
      ms.add(6)
      ms.trash
      ms.rating.should < 0.6
    end

    it "should not decrease rating to less than 0" do
      ms = FactoryGirl.create(:monthly_score)
      ms.add_num_of_pics_viewed(10)
      ms.trash
      ms.rating.should == 0
    end
  end

  describe "#rating" do
    it 'should never exeed 1 even if score added more than num of pics' do
      ms = FactoryGirl.create(:monthly_score)
      ms.add_num_of_pics_viewed(10)
      ms.add(11)
      ms.rating.should == 1
    end
  end

  describe "#months_from_now" do
    it "return the number of month from now" do
      MonthlyScore.new(year: 2011, month: 2).
              months_from(Date.new(2011, 4, 1)).should == 2

      MonthlyScore.new(year: 2011, month: 2).
              months_from(Date.new(2011, 2, 1)).should == 0

      MonthlyScore.new(year: 2010, month: 6).
              months_from(Date.new(2011, 2, 1)).should == 8

    end
  end
end