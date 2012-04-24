FactoryGirl.define do
  factory :monthly_score, :class => MonthlyScore do |ms|
    ms.year 2011
    ms.month 1
    ms.association(:flickr_stream, factory: :fave_stream)
    ms.score 0
  end
end