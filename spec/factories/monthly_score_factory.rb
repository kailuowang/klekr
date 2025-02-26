FactoryBot.define do
  factory :monthly_score, :class => MonthlyScore do
    year { 2011 }
    month { 1 }
    association :flickr_stream, factory: :fave_stream
    score { 0 }
  end
end